# Ayr Release

In this release the MARTe2-demos-sigtools is moved to a separate repository to distinguish the
configuration files and scripts from the dependencies and base platform.   This makes it easier
for docker multistage releases to avoid caching inefficiencies.

## User Story 0007 : FileWriter Demos

A set of configurations that demonstrate the range of functionality provided by the FileWriter
datasource, contributed by Richard Padden have been added.
