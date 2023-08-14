# zero-shot-NLG-from-KGs-data
Supplemental data for our MMNLG 2023 publication "Using Large Language Models for Zero-Shot Natural Language Generation from Knowledge Graphs".

# Mechanical Turk data
A cleaned, filtered version of the data returned from our Mechanical Turk form has been uploaded as mechanical_turk_data_cleaned.csv. The differences between this file and the original .csv file downloaded from MTurk are the following:
* The unique worker IDs have been replaced by anonymised strings of the type "Worker X", where X is a number from 1 to 34.
* The "lifetime approval rate", "approval rate in last 30 days" as well as "approval rate in last 7 days" columns have been removed (the numbers in these columns were connected to tasks published in connection to other experiments unrelated to this project).
* Additional columns have been added to interpret the JSON object stored in the column "Input.model_triples_json" (which stored the seven triples shown to participants as well as two distractor triples). The original JSON data is kept in the file for completeness. The new columns are named "First.Triple", "Second.Triple" etc., and "First.Distractor.Triple" and "Second.Distractor.Triple" for the distractors.
* For each triple, a column has also been added containing either the string "present", "absent" or "hallucinated" depending on how the crowdworker annotated that triple. Because we used radio buttons, each option originally got its own column, which is harder to read and interpret programmatically. The original columns have, however, been kept in the file for completeness. The new columns are named "First.Triple.Annotation", "Second.Triple.Annotation" etc.

The R script that was used to convert the original MTurk .csv file into the filtered and cleaned version is also included as "clean_mturk_data.R".
