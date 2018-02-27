# Corpus = structured collection of texts


# Need to make sure different different features are dealt with

library(tm)
library(e1071)
library(caret)
library(dplyr)
adverts_csv_name <- 'data\\all_full_advert_data.csv'

df <- read.csv(adverts_csv_name, stringsAsFactors = FALSE) %>%
  mutate(
  )



x <- df[1:8,]
test <- df[9:11,]

# splitting to text vector and 1/0 outcomes column
train <- x[, "Test"]
labs <- x[, "Effective."]

test.dat <- test[, "Test"]
test.labs <- test[, "Effective."]


# viewing proportion of the two outcomes
prop.table(table(labs))


# converting the text vector to a corpus
train.corpus <- Corpus(VectorSource(train))
test.corpus <- Corpus(VectorSource(test.dat))


# looking at the first set of text
train.corpus[[1]]$content


# change all text to lower case
train.corpus <- tm_map(train.corpus, content_transformer(tolower))
test.corpus <- tm_map(test.corpus, content_transformer(tolower))


# remove numbers
train.corpus <- tm_map(train.corpus, removeNumbers)
test.corpus <- tm_map(test.corpus, removeNumbers)


# removing stopwords (eg: and, to but, etc)
# stopwords() creates a vector of given words we're not interested in
train.corpus <- tm_map(train.corpus, removeWords, stopwords())
test.corpus <- tm_map(test.corpus, removeWords, stopwords())


# remove punctuation
train.corpus <- tm_map(train.corpus, removePunctuation)
test.corpus <- tm_map(test.corpus, removePunctuation)


# normalise whitespace
train.corpus <- tm_map(train.corpus, stripWhitespace)
test.corpus <- tm_map(test.corpus, stripWhitespace)

# calling functions inside tm_map() doesn't seem to play well
# with dplyr

# looking at the first set of text
train.corpus[[1]]$content
test.corpus[[1]]$content

# creating a sparse matrix, breaking the string into individual 
# elements (ie, words) which are between 2 and Inf. characters long
train.sparse <- TermDocumentMatrix(train.corpus, 
                                   control = list(global = c(2, Inf)))

test.sparse <- TermDocumentMatrix(test.corpus, 
                                  control = list(global = c(2, Inf)))

# the above process of breaking a string down into individual elements
# is known as Tokenising


# overview of our new model matrix
inspect(train.sparse[1:5, 1:5])
dim(train.sparse)

inspect(test.sparse[1:5, 1:3])
dim(test.sparse)


# looking at all words which appear at least twice
findFreqTerms(train.sparse, 2)


# as Naive Bayes is trained on categorical variables, want to replace
# all instances of >0 with "Yes" and =0 with "No", as a factor
converter <- function(x) {
  x <- ifelse(x > 0, 1, 0)
  x <- factor(x, levels = c(0, 1), labels = c("No", "Yes"))
  return(x)
}

train.sparse <- apply(train.sparse, 1:2, converter)
test.sparse <- apply(test.sparse, 1:2, converter)


# transposing
train.sparse <- t(train.sparse)
test.sparse <- t(test.sparse)


# training the model
nb.mod <- naiveBayes(train.sparse, labs, laplace = 1)


# looking at frequency tables for first 3 words
nb.mod$tables[1:3]


# using the model to predict things
pred.nb <- predict(nb.mod, test.sparse, type = "raw")


# simplifying the output to binary, depending on whether above or below 0.5
pred.nb <- ifelse(pred.nb[, "1"] >= 0.5, 1, 0)


# can then check test results with:
confusionMatrix(pred.nb, test.labs)
