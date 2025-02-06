# abymod-masters-project

Modelling the structure of Complimentarity Determining Region (CDR) loop CDR-H3 is difficult. Even alpha-fold struggles with the region, which is disordered and has a remarkably varied structure that appears not to fall into any discrete structural classes. It is this loop that limits the accuract of antibody structural models derived from Homology Modelling. 

In this project, using the software abYmod as a base, I determined the most effective parameters to model CDR-H3. 

Additionally, it is important to know how good the resultant structures might be. For this, I designed a machine learning algorithm that would predict the accuracy of the CDR-H3 loop given a sequence with unknown structure, based on the algorithms ability to predict known structures in PDB.

![alt text](https://github.com/CharlieBarker/abymod-masters-project/blob/master/masters_abstract.png)


This was done using the Repeated Incremental Pruning to Produce Error Reduction (RIPPER) Algorithm

RIPPER (Repeated Incremental Pruning to Produce Error Reduction) is a rule-based machine learning algorithm used for classification tasks. It is particularly useful for interpretable rule extraction and binary/multiclass classification problems.
