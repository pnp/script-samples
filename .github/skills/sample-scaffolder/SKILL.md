---
name: sample-scaffolder
description: This skill is designed to take a script sample that has been submitted as a PR and scaffold it into the sample format expected by the repository.
---

# Sample Scaffolder Skill

This will wrap the scaffolding process for a script sample that has been submitted as a PR. It will take the sample and scaffold it into the format expected by the repository.

## Expectations of the sample

- README.md file
- assets folder with sample.json file
- assets folder with a sample image

## Step by Step Workflow

There is a sample template folder called `scripts/_template-script-submission` that has the expected format for the sample.
It contains 
- README.md file
- assets folder with template.sample.json file
- assets folder with a sample image

When running this skill, it should be pointed at the folder in which the sample files are located, e.g. `scripts/my-sample/`.

This skill should

- If a readme.md file is not present, it should create one using the template readme.md file and fill in the relevant information from the sample submission.
- Copy the template.sample.json file to the assets folder and rename it to sample.json. It should then fill in the relevant information from the sample submission into the sample.json file.
- Copy the sample image to the assets folder.
