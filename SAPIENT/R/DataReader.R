library(dplyr, include.only = c("slice"))
`%>%` <- magrittr::`%>%`

extract <- function(paths, filenames) {
    # Creates the stop words regex for cleaning the data using the TidyText's
    # stop word list
    stopwords_regex <- paste(tidytext::stop_words$word, collapse = '\\b|\\b')
    stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')

    # Iterates through all PDF files in the folder, reads, and cleans their
    # content
    texts <- list()
    for (path in paths) {
        # Iterates through each document's strings and concatenates it into one
        # single string
        text <- ""
        for (str in pdftools::pdf_text(path)) {
            text <- paste(text, str, sep = " ")
        }

        # Removes stop words from the text, as well as non-alphanumeric and
        # non-punctuation characters
        text <- trimws(gsub("\\s+", " ", text))
        text <- trimws(gsub("Public Disclosure Authorized", "", text))
        text <- trimws(gsub("Document of The World Bank", "", text))
        text <- trimws(gsub("Document o f The World Bank", "", text))
        text <- trimws(gsub("FOR OFFICIAL USE ONLY", "", text))
        text <- trimws(gsub("For Official Use Only", "", text))
        text <- trimws(gsub("FOR OFFICIAL, USE ONLY", "", text))
        text <- trimws(gsub("The World Bank", "", text))
        text <- trimws(gsub("[^[:alpha:] .,]", '', text))
        text <- stringr::str_squish(text)

        # Concatenates all documents into one list containing all of them. Each
        # item in the list is a whole document
        texts <- c(texts, text)
    }

    # Creates the regex string for cleaning the filenames
    p_types <- c('PAD_', 'PID_', 'PGD_')
    p_types = paste(p_types, collapse = '\\b|\\b')
    p_types = paste0('\\b', p_types, '\\b')

    # Creates the tibble containing all the file names and the extracted texts
    result <- tibble::tibble(Project = filenames,
                             Text = texts)
    
    return(result)
}


tidify <- function(df,
                   token = 'sentences',
                   n = 2,
                   low_lim = 0.65,
                   up_lim = 0.7,
                   network_mode = FALSE,
                   export_json = FALSE,
                   version_name = NULL) {

    # Creates the stop words regex for cleaning the tokens
    stopwords_regex <- c('[^a-zA-Z\\d\\s:]', as.list(tidytext::stop_words$word))
    stopwords_regex <- paste(stopwords_regex, collapse = '\\b|\\b')
    stopwords_regex <- paste0('\\b', stopwords_regex, '\\b')

    # Iterates through the tibble with the documents and their texts, and
    # tokenizes them. This will create several rows for each document, every row
    # containing a token (sentence, n-gram, etc.)
    tibblist <- list()

    for (i in 1:nrow(df)) {
        # Extract every individual document by slicing the input tibble
        document <- df %>%
            slice(i)

        # Decides what to do regarding the input tokens
        if (token == 'ngrams') {
            document <- tidytext::unnest_tokens(document,
                                                Text,
                                                Text,
                                                "ngrams",
                                                n = n,
                                                to_lower = TRUE)
        } else {
            document <- tidytext::unnest_tokens(document,
                                                Text,
                                                Text,
                                                token,
                                                to_lower = TRUE)
        }

        # Cleans each document's token tibble
        document <- document %>%
            dplyr::count(Project, Text, sort = TRUE, name = 'Frequency') %>%
            dplyr::filter(stringr::str_detect(Text, "[:alpha:]")) %>%
            dplyr::filter(!stringr::str_detect(Text, '[.]{3}|[. ]{4}')) %>%
            dplyr::filter(nchar(Text) > 15)

        # Slices each document's token tibble with the range of data required by
        # the user and set by the parameters 'low_lim' and 'up_lim'. These are
        # retrieved by the frequency of each token
        document <- document %>%
            dplyr::slice(
                round(nrow(document) * low_lim, 0):round(nrow(document) *
                                                             up_lim, 0))

        # Cleans further the remaining tokens
        document <- document %>%
            dplyr::mutate(Text = trimws(
                stringr::str_replace_all(Text, stopwords_regex, ''))
            ) %>%
            dplyr::mutate(Text = stringr::str_squish(
                trimws(stringr::str_replace_all(Text, '[^[:alpha:] ]', '')))
            )

        # Concatenates all the document's token tibbles into a list of tibbles
        # called 'tibblist' (one document per iteration)
        tibblist <- c(tibblist, list(document))
    }

    # Concatenates the list of tibbles into a single tibble
    tibblist <- tibble::as_tibble(data.table::rbindlist(tibblist))

    tibblist <- tibblist %>%
        dplyr::mutate(Frequency = NULL)

    tibblist <- tibblist %>%
        dplyr::mutate(Target = 'No map.NA')

    return(tibblist)
}
