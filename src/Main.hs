{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}

module Main where

import Data.Text
import Data.Text.Lazy (toStrict)
import Text.Blaze.Html.Renderer.Text
import Text.Hamlet
import Web.Spock.Safe

-- Everything happens at: https://questio.ns/<speaker>/<talk>
-- Of course, speaker info is at https://questio.ns/<speaker>

data ViewerQuestion = ViewerQuestion { content :: String, submitter :: String }
data Question = Question ViewerQuestion
              | RephrasedQuestion { summary :: String, duplicates :: [ViewerQuestion] }
data Talk = Talk { slug :: String, title :: String, questions :: [Question] }
data Speaker = Speaker { username :: String, name :: String, talks :: [Talk] }

port = 8080

homePage :: Html
homePage = [shamlet|
<body>
  <h1>Questio.ns
  <h2>For Audience Members
  <p>The speaker should have provided a simple URL for you to post questions at. Check the bottom of their slides, maybe it’s there. We don’t publish these URLs directly to avoid them being used by those not watching the presentation.
  <h2>For Speakers
  <p>It’s easy to
    <a href="">sign up
    and add your own talks.
|]

speakerPage :: Text -> Html
speakerPage speaker = [shamlet|
<body>
  <form url="/#{speaker}">
    <h4>New talk title
    <input id="title">
|]

addATalk :: Text -> Maybe Text -> Maybe Text -> Html
addATalk speaker title slug = [shamlet|
<body>
  <form url="/#{speaker}">
    <h4>New talk title
    <input id="title">
|]

questionPage :: Text -> Text -> Html
questionPage speaker talk = [shamlet|
<body>
  <form url="/#{speaker}/#{talk}">
    <h4>Question for #{talk} by #{speaker}
    <textarea id="question">
    <h4>Who’s asking?
    <input id="submitter">
|]

addAQuestion :: Text -> Text -> Maybe Text -> Maybe Text -> Html
addAQuestion speaker talk question submitter = [shamlet|
<body>
  <form url="/#{speaker}/#{talk}">
    <h4>Question for #{talk} by #{speaker}
    <textarea id="question">
    <h4>Who’s asking?
    <input id="submitter">
|]

format = html . toStrict . renderHtml

main :: IO ()
main = runSpock port (spockT id (do
  get   root          (format homePage)
  get   var           (format . speakerPage)
  post  var           (\speaker -> do
    title <- param "title"
    slug  <- param "slug"
    format (addATalk speaker title slug))
  get  (var <//> var) (\speaker talk -> format (questionPage speaker talk))
  post (var <//> var) (\speaker talk -> do
    question  <- param "question"
    submitter <- param "submitter"
    format (addAQuestion speaker talk question submitter))))
