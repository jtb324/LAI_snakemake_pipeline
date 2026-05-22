# We are going to handle the chromosome configuration here and validate what the user provided
user_chrom_input = config.get("chromosomes")

VALID_CHROM_OPTIONS = set([str(i) for i in range(1,23)])

match user_chrom_input:
    case "autosomes":
        CHROMOSOMES = [str(i) for i in range(1,23)]
    # Check if the user provided a list and make usre it is not empty
    case list() as chrom_list if len(chrom_list) > 0:
        chrom_list = [str(i) for i in chrom_list]
        if invalid_value := (set(chrom_list) - VALID_CHROM_OPTIONS):
            raise ValueError(
                f"\n[Config Error]: The following chromosome values are not supported: {invalid_found}\n"
                f"Supported values are integers 1-22."
            )
        CHROMOSOMES = chrom_list
    # Handle the case where the user just gives a string or integer
    case int() | str() as user_val:
        if str(user_val) not in VALID_CHROM_OPTIONS:
            raise ValueError(
                f"\n[Config Error]: The following chromosome values are not supported: {user_val}\n"
                f"Supported values are integers 1-22."
            )
        CHROMOSOMES = [str(user_val)]
    case _:
        raise ValueError(
            f"\n[Config Error]: Invalid value, {user_chrom_input}, provided for chromosomes in config.yaml.\n"
            f"Allowed Values are 'autosomes', a list of chromosomes, or a single chromosome."
        )
        
# We are going to make sure the flare jar exists and if it doesn't then we are going to download it
flare_jar_path = config["flare"]["flare_jar_path"]

if flare_jar_path == "" or not Path(flare_jar_path).exists():
    FLARE_JAR = "resources/flare.jar"
else:
    FLARE_JAR = flare_jar_path