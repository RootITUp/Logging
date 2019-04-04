## 2.9.1 (2019-03-15)

- [NEW] Added Windows EventLog target (thx to @tadas)
- [FIX] Fixed Write-Log -Arguments detection
- [ADD] powershellgallery publishing on build

## 2.6.0-ci.10 (2018-10-24)

- [FIX] copyright string in mkdocs.yml
- [FIX] Build version for CD

## 2.4.13 (22/10/2018)

- [ADD] Caller function in message template

## 2.4.12 (21/09/2018)

- [ADD] Seq target (thx @TheSemicolon)
- [ADD] $ExceptionInfo paramter to Write-Log to add Error tracing

## 2.4.11 (17 August, 2018)

- Fixed custom targets for locations outside module folder (#20 thx to @jeremymcgee73)

## 2.4.10 (14 May, 2018)

- Fixed ElasticSearch target
- Added some more documentation
- Minor tweaking

## 2.4.9 (10 April, 2018)

- Implement OverrideColorMapping for Console target
- Implement format [DateTimeFormatInfo] usage and tests

## 2.4.8 (Febraury 27, 2018)

- Fixed email configuration address parsing

## 2.4.7 (November 6, 2017)

- Fixed slack logging target

## 2.4.6 (September 12, 2017)

- Set runspace ApartmentState to MTA
- Set min runspaces equals to 1
- Set max runspaces equals to NUMBER_OF_PROCESSORS + 1

## 2.4.5 (April 19, 2017)

- Fixed timestamp based on system locale

## 2.4.4 (March 13, 2017)

- Fixed module autoloading timing

## 2.4.3 (January 10, 2017)

- Fixed build script to release on powershelgallery only on master branch

## 2.4.2 (January 10, 2017)

- Fixed minor issues in internal functions
- Added new Pester tests

## 2.4.1 (December 29, 2016)

- Fixed deployment issues
- Moved to AppVeyor CI

## 2.4.0 (December 28, 2016)

- Moved to psake build tool
- Moved to platyps doc generation tool
- Major folder structure change













