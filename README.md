# Cloud Machine Benchmarker

Provision a one-off compute cluster to benchmark various instance specifications and determine the best configuration for your workload.

Compute instances self-destruct to avoid faster machine types finishing the benchmark early and sitting idle until the slowest instances complete.

## Usage

Configure `gcp_project`, `gcp_region` & `gcp_zone` and `objectstore`:

```
# Google Cloud
gcp_project = SET_YOUR_PROJECT
gcp_region  = "europe-west4"
gcp_zone    = "europe-west4-b"

# Storage
objectstore = {
    bucket   = SET_YOUR_BUCKET
    class    = "REGIONAL"
    location = "europe-west4"
}
```

`compute.tf` contains a local variable which covers many typical machine types and configurations.

`metadata_startup_script` in `compute.tf` contains all the compute logic:

- Updates the compute image
- Install Google Cloud Ops Agent for recording metrics
- Your workload between `# Edit below` and `# Don't edit below`
- Sync `${RESULTS}/` directory to a timestamped Google Cloud Storage bucket
- Self-destruct the compute instance

Run `terraform apply` to build all the infrastructure needed and start a benchmark cycle. Subsequent runs of `terraform apply` start a new benchmark cycle with new ID's.

Results are stored in timestamped folders in the provided bucket.

## Dashboards

Instances are labelled with `cmbench_type=compute` to filter to cmbench instances, and `cmbench_id` is the random ID of the current cycle.

## Example benchmark

[stress-ng](https://github.com/ColinIanKing/stress-ng) benchmarks CPU, Disk, Memory, etc..

Insert this block into `metadata_startup_script`:

```bash
# Stress-ng (https://github.com/ColinIanKing/stress-ng)
apt-get install -y build-essential libapparmor-dev
STRESSNG_VER="0.14.01"
wget https://github.com/ColinIanKing/stress-ng/archive/refs/tags/V$${STRESSNG_VER}.tar.gz -P /var/tmp/
tar -xf /var/tmp/V$${STRESSNG_VER}.tar.gz
cd stress-ng-$${STRESSNG_VER}
CC=gcc make -j $(nproc)
./stress-ng --verbose --timestamp --yaml stress-ng.yaml --aggressive --cpu 0 --hdd 0 --metrics --perf --timeout 1m

## Stress-ng convert YAML to JSON using yq & jq
apt-get install -y jq
wget https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64.tar.gz -O - | tar xz
mv yq_linux_amd64 /usr/bin/yq
chmod +x /usr/bin/yq
cat stress-ng.yaml | yq -p yaml -o json | jq '(.. | ."date-yyyy-mm-dd"?) |= (select(. != null) | gsub(":";"-"))' > stress-ng.json

## Stress-ng tidy up
mv -v stress-ng.yaml $RESULTS
mv -v stress-ng.json $RESULTS
cd ..
```
