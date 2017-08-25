#/bin/env bash
for box in $(ls *x86_64.json)
do
    jq -s '.[0] * .[1]' $box ./scripts/post_processor_override.json \
        | tee $(echo $box | sed s/-x86_64/-vsphere/)
done

for box in $(ls *amd64.json)
do
    jq -s '.[0] * .[1]' $box ./scripts/post_processor_override.json \
        | tee $(echo $box | sed s/-amd64/-vsphere/)
done
