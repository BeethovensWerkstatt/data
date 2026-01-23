# data

This repository holds the data for all five modules of the "Beethovens Werkstatt" project (https://www.beethovens-werkstatt.de/).

## Content

The repository contains:

- **MEI files**: Various types of transcriptions and facsimile dimension data
  - Annotated transcriptions
  - Diplomatic transcriptions
- **SVG files**: Shapes traced on facsimile pages

Each module has a separate folder inside the `/data` path. The content is made accessible through the API implemented in the [BeethovensWerkstatt/api](https://github.com/BeethovensWerkstatt/api) repository.

## Automated Workflows

This repository includes GitHub workflows that:

- **Update data-cache**: Automatically render MEI files to SVG and create fluid transcriptions, storing them in the [BeethovensWerkstatt/data-cache](https://github.com/BeethovensWerkstatt/data-cache) repository
- **Build API**: Trigger the build and deployment of the API, which stores the data in an eXist-db database

## Module Structure

* `/module1` → `/var`
* `/module2` → `/arr`
* `/module3` → `/corr` or `/rev`
* `/module4` → `/sk`
* `/module5` → `/ed`

