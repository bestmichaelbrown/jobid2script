# jobid2script

This short script will take a given DNA Nexus job ID and reconstruct the "dx run" command that was used to run it. It looks up the job information using the DNA Nexus API, then writes out a bash script to the filename provided.

As long as the user has already installed the dx-toolkit and has jq version 1.5+, it should run without issue.

The latest version of the dx-toolkit can be downloaded here: https://wiki.dnanexus.com/Downloads

And the latest version of jq can be downloaded here: https://stedolan.github.io/jq/download/
