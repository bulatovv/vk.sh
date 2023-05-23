# shellcheck shell=sh

flatten_json() (
	# TODO: improve flatten for array of scalars
	jq_flatten='
		paths(scalars) as $path |
		{"key" : $path | join("_"), "value" : getpath($path)} |
		"\(.key)=\(.value)"
	'
	echo "$1" | jq -c "$jq_flatten"
)

# export json to env variables in format:
# { "key": "value" } -> export key=value
# { "key": { "subkey": "value" } } -> export key_subkey=value
# { "key": [ "value1", "value2" ] } -> export key_0=value1; export key_1=value2
export_json() {
	old_IFS=$IFS
	IFS="
"	
	for keyval in $(flatten_json "$1"); do
		keyval="${keyval#?}"
		keyval="${keyval%%?}"
		keyval=$(printf "%b" "$keyval")

		export "${keyval?}"
	done

	IFS=$old_IFS
}
