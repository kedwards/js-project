#!/usr/bin/env sh

opts=':bc:d:f:s:t:p:h'

usage() {
  echo "Error ${1}"
  echo "Usage: ${script_name} options"
  echo "options:"
  echo "  -b | use bump script"
  echo "  -c | container name (* required)"
  echo "  -d | build file (default: Dockerfile)"
  echo "  -f | file to bump with version"
  echo "  -h | print this help menu"
  echo "  -p | push docker image to organization (ex. -p org)"
  echo "  -s | path to source files (default: .)"
  echo "  -t | docker image tag (* required if -b not found)"
  exit 1
}

script_name=${0##*/}
script_dir="$( cd "$( dirname "$0" )" && pwd )"
script_path=${script_dir}/${script_name}

# defaults
bump=false
push=false
build_path=.
build_file=Dockerfile

while getopts ${opts} opt
do
  case "$opt" in
    b)  bump=true
        ;;
    c)  container_name="${OPTARG}"
        ;;
    d)  build_file="${OPTARG}"
        ;;
    f)  bump_file="-f ${OPTARG}"
        ;;
    p)  org=${OPTARG}
        ;;
    s)  build_path="${OPTARG}"
        ;;
    t)  build_tag="${OPTARG}"
        ;;
    h)  show_help
        exit 1
        ;;
    \?)
        show_help "Invalid Option"
      exit 1
        ;;
  esac
done
shift $(($OPTIND - 1))

[ -z ${container_name} ] && usage "build tag cannot be empty"
[ -z ${build_tag} ] && [ ${bump} = false ] && usage "build tag required or enable bump script with -b"
[ ${bump} = true ] && [ ! -x /usr/bin/ver-bump ] && usage "cannnot find ver-bump executable, install with npm -g "

if [ ${bump} = true ];
then
  cd ${build_path} && \
  ver-bump -n ${bump_file} && \
  build_tag=$(node -p "require('./package.json').version")
fi

docker build \
  --file ${build_path}/${build_file} \
  --no-cache \
  --build-arg GIT_COMMIT=$(git log -1 --format=%h) \
  --build-arg BUILD_DATE=$(date +%FT%T%Z) \
  --build-arg VERSION=${build_tag} \
  -t ${container_name}:${build_tag} \
  ${build_path}/

[ ${push} = true ] && docker push ${org}/${container_name}:${build_tag} || exit 0