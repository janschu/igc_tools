# IGC Tracks to OGC API Features

## Background
The establishment of common data infrastructures for different kinds of data is on the research agenda for several years now. In the geospatial domain lots of efforts have been spent to build 'Spatial Data Infrastructures (SDIs)' - e.g the European Spatial Data Infrastructur for environmental data ([INSPIRE](https://inspire.ec.europa.eu/)). 
The overall architecture of those SDIs is based on specialised and complex services, standardised by the [Open Geospatial Consortium (OGC)](https://www.ogc.org/). Specific Map Servers (e.g. [Geoserver](https://geoserver.org/)) offer those service interfaces but require specific runtimes, configurations and hosting requirements - this can be quite complex for data providers.

## Goal
On a first step this project is intended to be a proof of concept: 'It is possible to provide spatial data as standard OGC service with an [Internet Computer - IC](https://internetcomputer.org/) canister.'
On a later stage, the specific functionalities of the IC shall be used to test the match between existing SDIs and modern blockchain approaches - but there are lots of aspects to be discussed in a wider group. 

- Identifier management by using the canister ids
- access and ownership using Internet Identity
- verify data authenticity
- split costs for hosting and software provision 
- ...

## Current implementation
A simple test-setup takes spatial data in the [IGC GNSS Tracks](https://en.wikipedia.org/wiki/IGC_(file_format)) format and provide an [OGC API Features](https://www.ogc.org/standards/ogcapi-features) to those data. 


