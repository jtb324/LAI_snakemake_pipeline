from snakmake.utils import min_version

min_version("###")

# load the configuration file
configfile: "config.yaml"
# Setup the report
report: "report/flare_workflow.rst"

# load the snakemake rules
include: "rules/load_config.smk"
include: "rules/flare.smk"

rule all:
    input:
        expand(rules.flare_call.output, chrom=CHROMOSOMES)
        expand(rules.index_vcf.output, chrom=CHROMOSOMES)