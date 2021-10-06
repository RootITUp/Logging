# CHANGELOG

## 4.8.3 (2021-10-06)



## 4.8.2 (2021-03-15)



## 4.8.1 (2021-02-18)



## 4.8.0 (2021-02-11)



## 4.7.1 (2021-02-11)


- [ADD] Teams target now support additional body types for adaptive cards (@jangins101)
- [FIX] Refactored Teams target (@jangins101)
- [FIX] Removed formatting timestamp on log event creation, this caused lost of milliseconds later on

## 4.5.0 (2020-10-22)


- [ADD] Teams target now support additional body types for adaptive cards (@jangins101)
- [FIX] Refactored Teams target (@jangins101)
- [FIX] Removed formatting timestamp on log event creation, this caused lost of milliseconds later on

## 4.4.0 (2020-06-17)

- [FIX] NotifyBeginApplication/NotifyEndApplication calls not needed (#99)
- [FIX] Fix startup race condition (#100) (@Tadas)
- [FIX] Fixed an issue in AzureLogAnalytics target (#102) (@Glober777)
- [FIX] Resolve relative Path in File target (#103) (@Tadas)
- [FIX] Target name is case insensitive (#106) (@Tadas)

## 4.3.2 (2020-05-28)

- [FIX] SEQ: fix url when ApiKey is used (#96) (@gahujipo)

## 4.3.1 (2020-05-28)

- [NEW] added target for Azure Log Analytics Workspace (thx to @manualbashing)
- [NEW] added target for Webex Teams (thx to @itshorty)
- [FIX] fixed module autoload (thx to @Tadas)
- [FIX] module don't hang shell exit (thx to @Tadas) #82

## 4.2.13 (2020-02-25)

## 4.2.12 (2019-11-08)

## 4.2.11 (2019-09-23)

- [FIX] Closed issue #66 where messages are lost on Powershell ISE
- [MOD] Decreased `Wait-Logging` timeout from 5 minutes to 30 seconds

## 4.2.7 (2019-09-19)

## 4.2.6 (2019-09-13)

In this release we worked out an issue about setting default
level or formatting was not honored by the already configured
targets (#67) and one about level ignored when dispatching messages
to targets (#68)

Thanks to: @ZamElek

## 4.2.3 (2019-08-27)

## 4.2.2 (2019-08-05)

In this minor release we fixed an annoying issue about how the module loads the available targets.
Now the loading routine is run inside the runspace to isolate the scope where the targets scriptblock is created.

- [BUG] Major code update to address issue #63
- [FIX] `Set-LoggingDefaultLevel` sets default level on cofigured targets too (#61, #58)
- [MOD] Removed validation on parameter Arguments

## 4.1.1 (2019-05-20)

- [NEW] Added timestamputc to log message properties #48
- [NEW] Added Icons configuration to Slack target to map Log Levels to emoji #53
- [FIX] Removed self loading in runspace
- [FIX] Moved Use-LogMessage to private functions
- [FIX] Added timeout to Wait-Logging to avoid hangs

## 4.0.3 (2019-04-15)

- [FIX] removed catalog generation until I get more grasp on the process

## 3.0.0 (2019-04-15)

This major release shouldn't break anything.
It should improve logging performance to a new level thanks to the amazing work of @tosoikea.

- [NEW] Advanced Logging Manager (thx to @tosoikea)
- [NEW] Module catalog generation on build
- [FIX] Filename token (thx to @lookcloser)
- [MOD] Code cleanup

## 2.10.0 (2019-04-04)

- [NEW] Added support for target default config
- [NEW] Added support for target initialization scriptblock
- [NEW] Added DynamicParam generation function
- [MOD] Synchronized variables are now Constant instead of ReadOnly (thx to @tosoikea)

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






