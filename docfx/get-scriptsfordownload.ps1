# Loop through all the samples
# Ensure the Downloads directory is in the GitIgnore file, we dont want to keep the files there

# in each sample file create a download directory
# find the #tab/*** in the markdown files README.md
# then find the next row containing ```powershell/bash
# capture all lines until the next ```
# save as file type .ps1 or .sh files
# naming convention is sample_name_tool_script.ps1 or sample_name_tool_script.sh like the sample directory

# add info header for the files e.g. script title, description, credit, created and modified dates, 
#       using the sample.json metadata

# move the file to the download directory

# save all the individual files as a zip file
# naming convention is sample_name_all_scripts.zip  like the sample directory

# Update the sample.json file with the URL for the sample scripts