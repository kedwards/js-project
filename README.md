# js-project

A meta reposiotry for js projects.

## Initilization

service can be one of `api` or `web`

```
SVC=${service}-init CMD='' make cmd
```
## Formatting / Linting / Testing

service can be one of `api` or `web`

command can be one of `fmt`, `lint`, or `test`

```
SVC=${service} CMD='yarn ${cmd}' make cmd
```

## Running

optionally you can add a service descriptor, can be one of `api` or `web`

```
[SVC=${service}] make up
```
