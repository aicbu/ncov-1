version 1.0

import "tasks/nextstrain.wdl" as nextstrain

workflow TERRA_NCOV {
  input {
    # ncov
    # Option 1: Pass in a sequence and metadata files, create a configfile_yaml
    File? A01_sequence_fasta
    File? A02_metadata_tsv
    File? A03_context_targz #<= optional contextual seqs in a tarball
    String? A04_build_name
    
    # Option 2: Use a custom config file (e.g. builds.yaml) with https or s3 sequence or metadata files
    File? A05_configfile_yaml
    File? A06_custom_zip      # optional modifier: add a my_profiles.zip folder for my_auspice_config.json
    String? A07_active_builds # optional modifier: specify "Wisconsin,Minnesota,Iowa"
        
    # Optional Keys for deployment
    String? A08_remote_url
    String? A09_NEXTSTRAIN_USERNAME
    String? A10_NEXTSTRAIN_PASSWORD
    
    # Path to pipeline repository and runtime information
    String RT_pathogen_giturl = "https://github.com/nextstrain/ncov/archive/refs/heads/master.zip"
    Int? RT_cpu
    Int? RT_memory       # in GiB
    Int? RT_disk_size
  }

  call nextstrain.nextstrain_build as build {
    input:
      # Option 1
      sequence_fasta = A01_sequence_fasta,
      metadata_tsv = A02_metadata_tsv,
      context_targz = A03_context_targz,
      build_name = A04_build_name,
  
      # Option 2
      configfile_yaml = A05_configfile_yaml,
      custom_zip = A06_custom_zip,
      active_builds = A07_active_builds,
  
      # Optional deploy to s3 site
      remote_url = A08_remote_url,
      NEXTSTRAIN_USERNAME = A09_NEXTSTRAIN_USERNAME,
      NEXTSTRAIN_PASSWORD = A10_NEXTSTRAIN_PASSWORD,
  
      pathogen_giturl = RT_pathogen_giturl,
      cpu = RT_cpu,
      memory = RT_memory,
      disk_size = RT_disk_size
  }

  output {
    File auspice_zip = build.auspice_zip
    File results_zip = build.results_zip
  }
}
