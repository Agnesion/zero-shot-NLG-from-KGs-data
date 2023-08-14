# Load MTurk original .csv file.
original.data = read.csv("results_mturk_merged.csv")
filtered.data = original.data

# Replace worker IDs with "Worker N" where N is 1 .. 34
worker.ids = c()

for (worker.id in unique(original.data$WorkerId)) {
  worker.ids[worker.id] = paste("Worker", length(worker.ids) + 1)
}

filtered.data$WorkerId = worker.ids[filtered.data$WorkerId]

# Remove the "approval rate" columns since they may partially identify the workers.
columns.to.remove <- c("LifetimeApprovalRate", "Last30DaysApprovalRate", "Last7DaysApprovalRate")
filtered.data = filtered.data[, !names(filtered.data) %in% columns.to.remove]

# Parse and unpack the JSON object showing which triples were part of the task shown to the user.
# At the same time, interpret the various Answer.statementX.Y columns into a single column per triple.
library(jsonlite)
filtered.data$First.Triple <- NULL
filtered.data$First.Triple.Annotation <- NULL
filtered.data$Second.Triple <- NULL
filtered.data$Second.Triple.Annotation <- NULL
filtered.data$Third.Triple <- NULL
filtered.data$Third.Triple.Annotation <- NULL
filtered.data$Fourth.Triple <- NULL
filtered.data$Fourth.Triple.Annotation <- NULL
filtered.data$Fifth.Triple <- NULL
filtered.data$Fifth.Triple.Annotation <- NULL
filtered.data$Sixth.Triple <- NULL
filtered.data$Sixth.Triple.Annotation <- NULL
filtered.data$Seventh.Triple <- NULL
filtered.data$Seventh.Triple.Annotation <- NULL

filtered.data$First.Distractor.Triple <- NULL
filtered.data$First.Distractor.Triple.Annotation <- NULL
filtered.data$Second.Distractor.Triple <- NULL
filtered.data$Second.Distractor.Triple.Annotation <- NULL

get.triple.annotation <- function(single.row, index) {
  column.prefix = "Answer.statement"
  
  if (index < 0) {
    column.prefix = "Answer.statement."
    index = -1 * index
  }
  
  value.present <- single.row[, paste(column.prefix, index, ".expressed", sep = "")]
  value.absent <- single.row[, paste(column.prefix, index, ".not.expressed", sep = "")]
  value.hallucinated <- single.row[, paste(column.prefix, index, ".hallucinated", sep = "")]
  
  if (value.present == "true") {
    return("present")
  } else if (value.absent == "true") {
    return("absent")
  } else if (value.hallucinated == "true") {
    return("hallucinated")
  } else {
    stop(paste("Couldn't find a good annotation for index", index, "of row", single.row))
  }
}

# There's probably a better way to do this than iterating but we only have to do it once.
for (line.index in 1:nrow(filtered.data)) {
  json.triples <- fromJSON(filtered.data[line.index, "Input.model_triples_json"])
  filtered.data[line.index, "First.Triple"] <- json.triples[json.triples$index == 0, "text"]
  filtered.data[line.index, "First.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 0)
  
  filtered.data[line.index, "Second.Triple"] <- json.triples[json.triples$index == 1, "text"]
  filtered.data[line.index, "Second.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 1)
  
  filtered.data[line.index, "Third.Triple"] <- json.triples[json.triples$index == 2, "text"]
  filtered.data[line.index, "Third.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 2)
  
  filtered.data[line.index, "Fourth.Triple"] <- json.triples[json.triples$index == 3, "text"]
  filtered.data[line.index, "Fourth.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 3)
  
  filtered.data[line.index, "Fifth.Triple"] <- json.triples[json.triples$index == 4, "text"]
  filtered.data[line.index, "Fifth.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 4)
  
  filtered.data[line.index, "Sixth.Triple"] <- json.triples[json.triples$index == 5, "text"]
  filtered.data[line.index, "Sixth.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 5)
  
  filtered.data[line.index, "Seventh.Triple"] <- json.triples[json.triples$index == 6, "text"]
  filtered.data[line.index, "Seventh.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], 6)
  
  filtered.data[line.index, "First.Distractor.Triple"] <- json.triples[json.triples$index == -1, "text"]
  filtered.data[line.index, "First.Distractor.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], -1)
  
  filtered.data[line.index, "Second.Distractor.Triple"] <- json.triples[json.triples$index == -2, "text"]
  filtered.data[line.index, "Second.Distractor.Triple.Annotation"] <- get.triple.annotation(filtered.data[line.index, ], -2)
}

# Output the resulting file.
# We intentionally keep the JSON column and the various annotation columns for completeness even though we interpreted
# them above.
write.csv(filtered.data, "mechanical_turk_data_cleaned.csv", row.names = FALSE)
