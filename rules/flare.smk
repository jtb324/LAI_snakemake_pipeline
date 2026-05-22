from pathlib import Path

OUTPUT_DIR = Path(config.get("flare_output_dir", "./"))
OUTPUT_FILE_PREFIX = config.get("output_file_prefix", "test")


# rule that will download the jar. This only runs if the jar is not installed or the path to the jar 
# is not specified/incorrectly speified
rule download_flare_jar:
    output:
        jar = FLARE_JAR
    params:
        url = config["flare"]["flare_jar_url"]
    shell:
        "wget -O {output.jar} {params.url}"

rule flare_call:
    input:
        geno_file = config["flare"]["vcf_input_template"],
        ref_panel = config["flare"]["ref_panel"],
        ref_vcf_template = config["flare"]["ref_vcf_template"],
        genetic_map_template = config["flare"]["genetic_map_template"]
        flare_binary = FLARE_JAR_BIN
    output:
        # We are going to define the output for the all the files flare produces. 
        lai_output = str(OUTPUT_DIR / f"{OUTPUT_FILE_PREFIX}_chr{chrom}.vcf.gz"),
        gai_output = str(OUTPUT_DIR / f"{OUTPUT_FILE_PREFIX}_chr{chrom}.global.anc.gz"),
        log_file_output = str(OUTPUT_DIR / f"{OUTPUT_FILE_PREFIX}_chr{chrom}.log"),
        model_output = str(OUTPUT_DIR / f"{OUTPUT_FILE_PREFIX}_chr{chrom}.model")
    params:
        random_seed = config.get("seed", 1234)
        # We need to get the prefix string so that we can pass that to the flare command
        output_prefix = lambda wildcards, output: output.vcf.replace(".vcf.gz")
        jvm_mem = config["flare"]["jvm_memory"]
    threads: config.get("threads", 8)
    shell:
        "java -Xmx{params.jvm_mem}g -jar {input.flare_binary} ref={input.ref_vcf_template} ref-panel={input.ref_panel} gt={input.geno_file} map={input.genetic_map_template} out={params.output_prefix} nthreads={threads} seed={params.random_seed}""

rule index_vcf:
    input:
        vcf = rules.flare_call.output.lai_output
    output: 
        # We need to generate a tbi file
        tbi = rules.flare_call.output.lai_output + ".tbi"
    shell:
        "tabix -p vcf {input.vcf}"