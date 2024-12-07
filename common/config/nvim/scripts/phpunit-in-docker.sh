#! /usr/bin/env bash

# Customize the following:
containerName=$NEOTEST_PHPUNIT_CONTAINER

# detect local path and remove from args
localPhpUnitResultPath='/tmp/phpunit-result.xml'
argsInput=${@}
runFile=$(echo $argsInput| awk '{print $1}')
phpTestPath=$(dirname "$runFile")
pushd $phpTestPath > /dev/null
projectPath="$(git rev-parse --show-toplevel)"
popd > /dev/null

subPath=$(awk -F '/vendor/' '{print $1}' <<< $projectPath)

## detect test result output
for i in $argsInput; do
    case $i in
        --log-junit=*)
            outputPath="${i#*=}"
            ;;
        *)
            ;;
    esac
done

# replace with local
args=("${argsInput/$subPath\//}")
args=("${args//(*}")

# Detect path
container=$(docker ps -n=-1 --filter name=$containerName --format="{{.ID}}")
phpunitPath=$(docker exec -it $container /bin/bash -c "[ -f vendor/bin/phpunit ] && echo vendor/bin/phpunit || echo bin/phpunit" | tr -d '\r')
dockerPath=$(docker inspect --format {{.Config.WorkingDir}} $container)

## debug
# echo "Raw ARGS: "${@}
# echo "Params:   "${args[@]}
# echo "Docker:   "$dockerPath
# echo "Local:    "$projectPath
# echo "Result:   "$outputPath
# echo "docker exec -i "$container" php -d memory_limit=-1 "$phpunitPath" "${args[@]}

# Run the tests
docker exec -it $container sh -c "$phpunitPath -d memory_limit=-1 ${args} --log-junit=${localPhpUnitResultPath}"

# copy results
docker cp -a "$container:$localPhpUnitResultPath" "$outputPath"|- &> /dev/null

# replace docker path to locals
sed -i '_' "s#$dockerPath#$projectPath#g" $outputPath
