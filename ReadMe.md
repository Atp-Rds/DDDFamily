mORMot test project: DDD persistence sample using ORM, depending on Aggregate
==============================================================

By atpRads, based on

- mORMot framework by Synopse:

     https://synopse.info/fossil/wiki?name=SQLite3+Framework
     
- mORMot samples:
    "Sample 35 - Practical DDD" By ab
    "Simple DDD persistence sample using ORM" By uian2000
    (...)
- mORMot documentation: 
    https://synopse.info/files/html/Synopse%20mORMot%20Framework%20SAD%201.18.html   
- ab's EKON presentations (Arnaud Bouchez - Synopse):
    http://blog.synopse.info/post/2017/10/24/EKON-21-Presentation
    http://blog.synopse.info/post/2018/11/12/EKON-22-Slides-and-Code)    

# Presentation

This is a test project, using mORMot framework, which try to show how to define a DDD persistence factory, depending on the context (using different context as Aggregates, stored as a whole), and their relationships (developed as an exercise to mORMot student).

# Details:
This sample, try to simulate a "family" (simplified) with 3 members (mother, father and son), and their relationships.

The sample project, which is a first approximation (and is "under construction", developed to learn about DDD and mORMot), tries to serve as reference to implement a DDD project with mORMot, trying to follow/show:

- DDD with mORMot: with clean architecture, with proper isolation and uncoupling, with clean folder hierarchy, based on EKON21 & EKON 22 presentations, and some project samples (like "Sample 35 - Practical DDD"), by ab (synopse.info)
(see ab's EKON presentations at http://blog.synopse.info/post/2017/10/24/EKON-21-Presentation and http://blog.synopse.info/post/2018/11/12/EKON-22-Slides-and-Code)

- The relationships between family members in a not polluted and isolated domain, with clean architecture: clean DDD objects, using PODO classes, following the Ubiquitous Language (see project's folder hierarchy, and some units like \dom\DomFamilyTypes.pas)

- How to store Aggregate as a whole, using mORMot ORM capabilities (which allows persistence ignorance too): Depending on Context (Mother, Father, Son or Family), aggregates stored as a whole (see regression tests at \infra\Infra*Repository.pas)

- How to update some properties and how can this change should be propagated to all aggregates, maintaining data consistency from application logic (see unit .\dom\DomFamilyServices.pas, see function "ChangeMothersName" at dom\DomFamilyServices.pas)

- To see how it stores the data on a real Database (using the integrated SQLite3 database engine in mORMot, see RegressionTestsToSQLite3 function at \infra\Infra*Repository.pas): You can see the generated SQLite3 database file (DDDFamilyTest.db), to see how the data is stored at database.


