# X-Road: Operational Monitoring Testing Strategy

Version: 0.4

Document ID: TEST-OPMONSTRAT

## 1 Introduction

### 1.1 Purpose

In this document, we define the testing strategy for the development project of the operational monitoring components of the X-Road system.

The testing strategy may be updated during the project according to the agreements between the parties.

A detailed testing plan will be delivered as a separate document in [[TEST-OPMON]](#TEST-OPMON).

### 1.2 Terms and Abbreviations

HTTP -- Hypertext Transfer Protocol  
HTTPS -- Hypertext Transfer Protocol Secure  
JMXMP -- Java Management Extensions Messaging Protocol  
SOAP -- Simple Object Access Protocol  
DSL -- Domain Specific Language  
CA -- Certification Authority  
TSA -- Timestamping Authority  
CI -- Continuous Integration  

### 1.3 References

<a name="HD_1">HD_1</a> -- Hanke lisa 1: X-tee monitooringu tehniline kirjeldus  
<a name="HD_2">HD_2</a> -- Hanke lisa 2: Mittefunktsionaalsed nõuded  
<a name="HD_4">HD_4</a> -- Hanke lisa 4: testimise korraldus  
<a name="ARC-OPMON">ARC-OPMON</a> -- Cybernetica AS. X-Road: Operational Monitoring Daemon Architecture  
<a name="PP">PP</a> -- Cybernetica AS. Tööde kirjeldus koos ajakavaga  
<a name="REC-OPMON">REC-OPMON</a> -- Cybernetica AS. X-Road Operational Monitoring: Requirements  
<a name="UC-OPMON">UC-OPMON</a> -- Cybernetica AS. X-Road: Operational Monitoring Daemon Use Case Model  
<a name="TEST-OPMON">TEST-OPMON</a> -- Cybernetica AS. X-Road: Operational Monitoring Testing Plan  

## 2 Requirements Relevant to Testing

The functional requirements of the monitoring system are described in [[REC-OPMON]](#REC-OPMON).  
The architecture of the system is described in [[ARC-OPMON]](#ARC-OPMON).  
The items of data that are collected and forwarded by the monitoring system, are defined in [[HD_1]](#HD_1).  
The required paths of data exchange are defined in [[HD_1]](#HD_1).  
The requirements of access control are defined in [[HD_1]](#HD_1).  
The proper default configuration of the system is defined in [[HD_1]](#HD_1).  
The non-functional requirements of the monitoring system are described in [[REC-OPMON]](#REC-OPMON) and [[HD_2]](#HD_2).

## 3 Testability of the System

The operational monitoring system is a machine-to-machine data exchange system, and the events that are relevant to monitoring can be triggered programmatically, once the necessary configuration has been carried out. Thus, the system lends itself very well to automated testing.

Regular X-Road message exchange as well as monitoring data exchange via all the required paths can be simulated for both integration and load testing. Because all the relevant configuration will be implemented as text files, modifying the configuration of the monitoring system can be scripted easily, if necessary.

## 4. Types of Testing Used

The required types of testing are defined in [[HD_4]](#HD_4). Additional types and levels of testing may be used if found necessary during the project. The additional types of testing, if any, will be documented in [[TEST-OPMON]](#TEST-OPMON).

### 4.1 Integration Testing

The integration tests will be used for testing the required functionality of the security servers and the operational monitoring daemon working together, while regular X-Road requests as well as monitoring data requests are handled. The goal is to cover the main functionality with automated tests. Manual tests will be carried out by the development team as needed, as well as during acceptance testing if necessary. The descriptions of manual tests will be provided in [[TEST-OPMON]](#TEST-OPMON).

### 4.2 Load Requirements and the Scope of Load Tests

A general test plan and the requirements for hardware for load testing was specified by RIA by e-mail (message ID CC0A4AA94EE060438CD300941B8EF1EED37D61@exc2a.ria.ee). 

Due to the asynchronous nature of the operational monitoring system, the overhead of request exchange is minimal, when operational data is stored. Operational data about each request is written to an in-memory operational data buffer at the security server and forwarded to the operational monitoring daemon in an asynchronous manner. In such a situation, the host running the security server will mostly experience additional load due to the forwarding of the records, especially during high loads or if operational data cannot be forwarded for some time.

Under a heavy load and if the operational monitoring database component is unavailable, the monitoring buffer may use a considerable amount of memory or drop the eldest operational data records before having forwarded these to the operational monitoring database component.

Thus, the focus of load testing is to find the balance between memory usage and possible data loss.

### 4.3 Unit Testing

Generally, unit tests are used for testing the behaviour of single units of code (functions, methods) with clearly defined inputs and outputs.

The required coverage and scope of unit tests have not been defined for this project. Thus, unit tests will be written for units of code that implement protocols, conversion between data formats etc, including tests against invalid or unexpected input. Such units of code will be isolated for testability.

For larger components that are used for control logic, system-wide data exchange as well as configuration, unit tests are not justified and will not be written. The behaviour and error handling of such components will be covered by automated or manual integration tests.

Unit tests will not be written for third-party protocol implementations (such as JMXMP).

## 5 The Team and the Workflow

The schedule of the project and the roles of the team are described in [[PP]](#project_plan).

The testing activities and the programming of tests are carried out by testers and developers. The architecture and the tools of testing are reviewed by the architect of the project.

Unit tests will be implemented by the developers in parallel with the functionality of the system. The scope of unit tests has been described (see [above](#4-3-unit-testing)). The build configuration of the project will set up to automatically run the unit tests at each build.

Integration and load testing will be carried out according to the following plan:
- *Elaboration phase:* the tools for testing at the required levels will be chosen and an initial testing plan will be written.
- *Construction phase:* the initial version of load tests will be written and the framework of automated integration tests will be constructed.
- *Transition phase:* The load tests and the automated integration tests will be implemented and integrated with the Continuous Integration system and the testing environment. If manual integration test cases are written, these will be formatted as part of [[TEST-OPMON]](#TEST-OPMON).

## 6 Tools, Languages and Libraries

The integration tests will be implemented in Python 3. During the Elaboration Phase, the approach and tools for describing the integration test steps will be selected. Also, the libraries required for networking, parsing of messages etc, will be selected during the Elaboration Phase.

The load tests will be programmed, and simulations will be described, in Scala and the Gatling DSL, with orchestration scripts programmed in Python 3.

Unit tests will be programmed in Java 8, using the JUnit library.

## 7 Management and Source Control of Automated Tests

All the source code and the necessary data and configuration files (or samples where necessary) of the integration, load and unit tests will be committed to the main Git development repository of the project. The tests and test data, once these are implemented, will be included in the pull request made at the end of each relevant iteration of the project.

## 8 Setup and Management of the Testing Environment. Continuous Integration

The testing environment and continuous integration setup during development will closely mimic the required target testing environment (as described in [[HD_4]](#HD_4)) with some additions. The relevant configuration files and documentation will be committed to the main Git development repository for simple migration to the target testing system.

The main automated testing environment will consist of the following virtual machines, with the name of the corresponding machine at RIA given in parentheses:
- Central server (*xtee7.ci.kit*)
- Management security server with a local monitoring daemon and a local Zabbix (*xtee8.ci.kit*)
- Security server with a local monitoring daemon and a local Zabbix (*xtee9.ci.kit*)
- Security server using the external monitoring daemon of the testing environment and a local Zabbix (*xtee10.ci.kit*)
- A mock SOAP server for providing X-Road services (*xtee2.ci.kit*)

The CA/TSA server of RIA (*xtee1.ci.kit*) will be used for trust services, to enable simple migration of the additions to the system's configuration back to RIA-s environment. The configuration of local name resolution will enable the host names used in RIA's testing system to be used in the automated testing environment of Cybernetica.

A SoapUI-based mock server will be used for providing the X-Road services necessary for testing the system. The configuration files of the mock services and the corresponding .war file will be committed to the main development repository.

The results of automatic integration tests and load tests will be browsable in the Continuous Integration system (Jenkins) at RIA after each run, once these have been implemented and the CI system has been configured.

The results of manual integration testing will be observable by the participants and written to a log file.

The results of unit tests will be browsable in the Continuous Integration system (Jenkins) at RIA after each build of the source tree, once the changes have been merged to the repository at RIA and the CI system has been configured.