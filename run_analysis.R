library(dplyr)

# Load files
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)

X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# Merge data
X <- rbind(X_train, X_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)

data <- cbind(subject, y, X)

# Name columns
names(data)[1:2] <- c("subject", "activity")
names(data)[3:ncol(data)] <- features$V2

# Extract mean and std
mean_std <- grepl("mean\\(\\)|std\\(\\)", features$V2)
data <- data[, c(TRUE, TRUE, mean_std)]

# Add activity names
data$activity <- factor(data$activity,
                        levels = activity_labels$V1,
                        labels = activity_labels$V2)

# Clean names
names(data) <- gsub("-", "", names(data))
names(data) <- gsub("\\(\\)", "", names(data))
names(data) <- gsub("^t", "time", names(data))
names(data) <- gsub("^f", "frequency", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))

# Create tidy dataset
tidy_data <- data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean), .groups = "drop")

# Save output
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
