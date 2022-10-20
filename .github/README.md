# The Open CSP framework

The perfect Mediawiki framework for corporate use.

## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)

## Requirements

To install the Open CSP framework, the following need to be installed:
- php version >=7.4 <8
- composer version >=2
- Mediawiki version 1.35
- ElasticSearch version 6.8

## Installation

Follow these steps to set up your Open CSP wiki:

0. [Install](https://www.mediawiki.org/wiki/Manual:Installing_MediaWiki) and [configure](https://www.mediawiki.org/wiki/Manual:Config_script) Mediawiki version 1.35 and make sure you can connect to an ElasticSearch instance.
1. Copy the instal script from [this github repo](https://raw.githubusercontent.com/Open-CSP/open-csp/development/.github/install_open_csp.sh) to your mediawiki server.
2. Run the install script
```sh
    ./install_csp.sh <mediawiki directory>
```

## Usage

If installation went succesful, the wiki should show some pages with basic usage instructions. More information can be found on [our website](https://open-csp.org).

## Support

Please [open an issue](https://github.com/Open-CSP/open-csp/issues/new) for support.
If you want more support, [contact us](https://wikibase-solutions.com/contact) for possibilities of continuous support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/Open-CSP/open-csp/compare/).
