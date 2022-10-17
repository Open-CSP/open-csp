# Common problems when installing the Open CSP framework

## The cloned repo still exists

When the install script tries to fetch the Open CSP code, but a file / directory `open-csp` exists in your current directory, you may get an error like this:
```txt
fatal: destination path 'open-csp' already exists and is not an empty directory.
```
You can solve this either by
- If the `open-csp` file or directory is important and you do not want to overwrite it, try executing the `install_open_csp.sh` script from a different location.
- If you do not recognise the `open-csp` file or directory, or the contents are not important, you can remove it with `rm -rf open-csp`.

## A missing github token

When you have not installed a github token for your composer, you get an error like this:

```txt
GitHub API limit (0 calls/hr) is exhausted, could not fetch 
https://api.github.com/repos/wikimedia/mediawiki-extensions-AdminLinks/commits/f05dd41a94bbbfbf707d4d7ac9911143657d6f9c. Create a GitHub OAuth token to go over the API rate 
limit. You can also wait until ? for the rate limit to reset.

When working with _public_ GitHub repositories only, head to https://github.com/settings/tokens/new?scopes=&description=Composer+on+wiki+example+com+1970-01-01+0000 to retrieve a token.
This token will have read-only permission for public information only.
[....]
Token (hidden):
```

You should add a github token to composer as described in the error message. Use the link from the error message, *not* the example link in this FAQ.

When you have a token, either enter it in the prompt, or add it to composer as follows:
```sh
composer config --global github-oauth.github.com YOUR_NEW_GITHUB_TOKEN
```

## No connection to ElasticSearch

When the default settings are not sufficient to connect to ElasticSearch, you get an error like this:

```txt
Could not establish a connection to Elasticsearch using ["localhost:9200"]
```

This issue can have different causes:
- Your ElasticSearch service is not running, or unresponsive. Try restarting it.
- The ElasticSearch service is not running on "localhost:9200". In this case, you should edit the `./settings/CSPSettings.php` file.
  Near the top of the file, there should be something like `$GLOBALS['smwgElasticsearchEndpoints'] = [ 'localhost:9200' ];`.
  You should change this value to point to the ElasticSearch endpoint that you need.
  *Note:* When re-running the install script, do _not_ overwrite your edited settings.
