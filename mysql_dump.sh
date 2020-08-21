#!/bin/sh

# set -x

script_name="$(basename "${0}")"

print_usage() {
	printf '\n%s\n' "${script_name} [-h] [-d FOLDER] [-c CLASSIFIER] [-p TEMPDIR]\
 [-- ARGS...]"
}


generate_timestamp(){
    date +'%Y%m%d_%H%M_%N'
}

if [ ! ${#} -gt 0 ]
then
	print_usage 1>&2
	exit 1
fi

classifier=""
destination="."
tmpdir="/tmp"
prefix="mysql_dump"

while getopts ":hc:d:p:" opt
do
    case ${opt} in
        c)
            classifier="${OPTARG}"
            ;;
        d)
            destination="${OPTARG}"
            ;;
        p)
            tmpdir="${OPTARG}"
            ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            ;;
    esac
done
shift $((OPTIND - 1))

destination="$(readlink -f "${destination}")"

if [ ! -d "${destination}" ]
then
    echo "'${destination}' is not a folder." 1>&2
    exit 1
fi

name="${prefix}${classifier}$(generate_timestamp).sql"

dump_file_dir="$(mktemp -d -p "${tmpdir}")"
cd "${dump_file_dir}"
zip_file="${destination}/${name}.zip"
mysqldump --no-tablespaces "${@}" > "${name}"
zip "${zip_file}" "${name}"
cd -
rm -rf "${dump_file_dir}"
