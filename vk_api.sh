# shellcheck shell=sh

vk_api() (
	set -- "$@" "access_token=${VK_TOKEN}" "v=${VERSION}"
	method="$1"; shift

	query=""
	while [ $# -gt 0 ]; do
		case "$1" in
			--*=*) query="${query}&${1#--}" ;;
			--*) query="${query}&${1#--}=$2"; shift ;;
			*) query="${query}&$1" ;;
		esac
		shift
	done

	if result=$(curl -sS -X POST --data "$query" "https://api.vk.com/method/${method}" 2>&1)
	then
		echo "$result" | 
			jq -rc ".response, .error.error_code, .error.error_msg" | (
				read -r response
				read -r error_code
				read -r error_msg

				if [ "$error_code" != null ]; then
					echo "VK_API_ERROR[${error_code}]: ${error_msg}" >&2
					return 1 
				fi

				echo "$response"
		)
	else
		echo "CURL_ERROR[$?]: $(echo "$result" | cut -d' ' -f3)" >&2
		return 1;
	fi

)

vk_bots_long_poll() (
    vk_api groups.getLongPollServer --group_id "$GROUP_ID" |
        jq -rc '.key,.server,.ts' | (
			read -r key
			read -r server
			read -r ts

			while true; do

				if ! answ=$(curl -sS "${server}?act=a_check&key=${key}&ts=${ts}&wait=25" 2>&1)
				then
					echo "$answ" >&2
					sleep 1
					continue
				fi
				
				failed=$(echo "$answ" | jq -rc '.failed')
				case "$failed" in
					null)
						echo "$answ" | jq -rc '.updates | .[]'
						;;
					2 | 3)
						answ=$(vk_api groups.getLongPollServer --group_id "$GROUP_ID")
						key=$(echo "$answ" | jq -rc '.key')
						;;
				esac
				
				ts=$(echo "$answ" | jq -rc ".ts")
			done
		)
)

vk_user_long_poll() (
    vk_api messages.getLongPollServer need_pts=1 lp_version=3 |
        jq -rc '.key,.server,.ts' | (
			read -r key
			read -r server
			read -r ts

			while true; do

				if ! answ=$(curl -sS "${server}?act=a_check&key=${key}&ts=${ts}&wait=25&mode=128&version=3" 2>&1)
				then
					echo "$answ" >&2
					sleep 1
					continue
				fi
				
				failed=$(echo "$answ" | jq -rc '.failed')
				case "$failed" in
					null)
						echo "$answ" | jq -rc '.updates | .[]'
						;;
					2 | 3)
						answ=$(vk_api groups.getLongPollServer --group_id "$GROUP_ID")
						key=$(echo "$answ" | jq -rc '.key')
						;;
				esac
				
				ts=$(echo "$answ" | jq -rc ".ts")
			done
		)

)
