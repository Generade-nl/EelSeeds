#Selecting seeds for TULIP from Illumina reads

For the eel genome assembly, we used Illumina data as seed sequences for TULIP. The criteria we used are a relaxed 'not too repetitive', as the point is mainly to eliminate seeds that will have many connections in the seed graph. Although TULIP will at some point recongize such tangles, it will first try to resolve the local structure into a linear scaffold, which simply takes a lot of time and contributes nothing to the final assembly. So, better to get rid of these sequences beforehand.<br>

There are probably many ways to select non-repetitive content. For the eel, we used FLASh to merge 2x150 bp reads, Jellyfish to count 25-mers, and two custom scripts to filter out merged reads that do not contain highly abundant 25-mers:<br>

1. **K-mer counting** <br>
  ```
  jellyfish count -m 25 -t 4 -s 200M -C -o jf  Anguilla_anguilla_PE280_NoIndex_L005_R1_001.fastq Anguilla_anguilla_PE280_NoIndex_L005_R2_001.fastq 
  jellyfish dump -c -t -L 25 jf > anguilla_jellyfish_25L25.dump
  ```
  ```
  head anguilla_jellyfish_25L25.dump 
  ```
  ```
  AAAAAAAAAAAAAAAAAAAAAAAAA	476,094
  GAAACTGAGACAGACTGCAGACTGA	34
  ATATAGAGTGCACAATGGTGTATAA	26
  AAACTCATGTATTGGACTTTATATT	32
  ...
  ```
  <br>

2. **Merging** <br>
  ```
  flash Anguilla_anguilla_PE280_NoIndex_L005_R1_001.fastq  Anguilla_anguilla_PE280_NoIndex_L005_R2_001.fastq --threads 1 --min-overlap 15 --max-overlap 200 --max-mismatch-density=0.1 --output-prefix=Anguilla_anguilla_15FLASh
  ```
  Results:
  ```
  [FLASH]     Total pairs:       39,321,964
  [FLASH]     Combined pairs:    11,466,259
  [FLASH]     Uncombined pairs:  27,855,705
  [FLASH]     Percent combined:  29.16%
  ```
  <br>
  
3. **Merged pair selection**<br>
  ```
  perl ./selectMergedEelReads.perl Anguilla_anguilla_15FLASh.extendedFrags.fastq anguilla_jellyfish_25L25.dump 150 25 0
  ```
  _Criteria:_<br>
  Minimum length 150<br>
  Suspect k-mers occur 25+ times<br>
  0% suspect k-mers allowed<br>
  
  11,597,761 kmers indexed<br>
  _6,767,726_ reads approved out of 11,449,623<br>
  <br>

4. **Select sequences of identical length (note: hardcoded lengths 270, 275, 280, 285)**<br>
  ```
  perl ./binLongEelReads.perl Anguilla_anguilla_15FLASh.extendedFrags.fastq_150_25_0.fasta 
  ```
  ```
  length 270  5,019,778 (subsets used with TULIP)
  length 275  3,932,744
  length 280  2,485,298
  length 285    873,058 (used with TULIP)
  ```
