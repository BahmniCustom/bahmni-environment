revision='{
    "go" : "https://ci-bahmni.thoughtworks.com/go/pipelines/value_stream_map/_jobname_/_pipelineCount_",
    "github": {
        "elis" : "https://github.com/Bahmni/OpenElis/commit/_sha_"
    }
}'

replace() {
    envValue=`env | egrep "$2=" | sed "s/$2=//g"`
    sed "s/$1/$envValue/g"
}

echo $revision | replace "_jobname_" "GO_PIPELINE_NAME" | replace "_pipelineCount_" "GO_PIPELINE_COUNTER" | replace "_sha_" "GO_REVISION_OPENELIS_GITHUB"

