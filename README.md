# NAME

Mail::SpamAssassin::Plugin::CHAOS, Version 1.1.0

# SYNOPSIS

- Usage:

            ifplugin Mail::SpamAssassin::Plugin::CHAOS
                    chaos_mode Manual
                    header          JR_UNIBABBLE            eval:from_lookalike_unicode()
                    describe        JR_UNIBABBLE        Frome Name Character Spoofs
                    score           JR_UNIBABBLE            3.0
                    ...
                    header          JR_SUBJ_EMOJI           eval:check_for_emojis()
                    header          JR_FRAMED_WORDS         eval:framed_message_check()
                    header          JR_TITLECASE            eval:subject_title_case()
                    ...
            endif



# DESCRIPTION

This is a SpamAssassin module that provides a variety of: Callouts, Handlers, And Object Scans (CHAOS).  To assist one's pursuit of Ordo Ab Chao, this SpamAssassin plugin provides over 20 unique Eval rules.

This plugin demonstrates SpamAssassin's relatively new (3.4) dynamic scoring capabilities:

        + Use PERL's advanced arithmetic functions.
        + Dynamic, Variable, and Conditional scoring.
        + Adaptive scoring (baseline reference).

This module can operate in the following modes:

- "Tag" mode sets the scores for all rules produced to a callout level of 0.01.  You can add or change rulenames using these Evals, but the description and soore remain fixed.  This is useful when first integrating this module into an existing SA system.  This is the default mode of operation.
- "Manual" mode allows you, the user, to set the Name, Describe, and Score fields for each Eval; in traditional SA fashion.
- "AutoISP" mode allows you to quickly scale the rules to ranges suitable for ISP/ESP use.

## Adaptive Scoring Configuration

- The rules provided by thie module are auto-scoring.  The scores are set to
a percentage of three values, the value at which mail is (1) Tagged as Spam,
(2) invokes Evasive Actions, and (3) Final Destination/Silent Discard.
These values must be set in the .cf configuration file.

    For example, if a particular rule scores 4.5 on this mail system, the rule
    score would be something like: $score = $pms->{conf}->{chaos\_tag} \* 0.64.  If
    you want to increase the scores provided by this module, just increase these
    values.  Conversely, decreasing these values results in lower scores.

            Default Values
        --------------
            chaos_tag 7
            chaos_high 14
            chaos_max 25


- In a pure-play, basic SpamAssassin environment, try setting these all these
values to 4.

# METHODS

- This module DOES require configuration for the Adaptive Scoring to work properly in different environments.

- This plugin provides many Eval routines, called in standard fashion from local SpamAssassin ".cf" configuration files.

## check\_for\_brackets()

- This is a Subject header test for Left and Right, Brackets, Braces, Parenthesis and their Unicode varients.  These are sometimes called Set, Framing, or Grouping Characters.  In Tag mode, JR\_SUBJ\_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR\_SUBJ\_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR\_SUBJ\_BRACKETS or <YOUR\_RULENAME> is appended with an "\_$count" whose score is 0.01. Example: YOUR\_RULENAME\_3.

## check\_from\_brackets()

- This is a test of the From Name field for Left, Right, Brackets, Braces, Parenthesis and their Unicode varients.  In Tag mode, JR\_FROM\_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR\_FROM\_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR\_FROM\_BRACKETS or <YOUR\_RULENAME> is appended with an "\_$count" whose score is 0.01. Example: YOUR\_RULENAME\_3.

## framed\_message\_check()

- This is a Subject header test that looks for the presence of Framed /
Bracketed words, lie: \[URGENT\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants!  In The Auto and Tag modes, the rule's
description will reflect the number of instances found.

- In Auto mode this score is variable, based upon the number of matches at or above
the defined count.  The default() count is 1.  When running in Tag mode, the score is
set to a callout level of 0.01.

## framed\_digit\_check()

- This is a Subject header test that looks for the presence of Framed /
Bracketed digits \[4\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants.  In The Auto and Tag modes, the
rule's description will reflect the number of instances found.

- In Auto mode, the score is variable, based upon the number of framed
digits at, or over, the defined count.  The default() count is 2.

## check\_for\_emojis()

- This is a Subject header test that looks for Unicode Emojis.  In Tag
mode JR\_SUBJ\_EMOJIS, or <YOUR\_RULENAME>, is set to a callout value of 0.01.
In AutoISP mode, JR\_SUBJ\_EMOJIS has a variable score based upon the number
of Emojis at, exceeding, the hit count.  In Manual mode, <YOUR\_RULENAME>
is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard
SpamAssassin fashion.  The Default() hit count is 3.

- In ALL modes, a callout is set containing the exact number of bracket
characters detected.  The rulename, JR\_SUBJ\_EMOJIS or <YOUR\_RULENAME> is
appended with an "\_$count" whose score is 0.01. Example: YOUR\_RULENAME\_3.
The rule's description will reflect the number of Emojis found.

## check\_from\_emojis()

- This is a test of the From Name field that looks for Unicode Emojis.
In Tag mode JR\_FROM\_EMOJIS, or <YOUR\_RULENAME>, is set to a callout value of
0.01.  In AutoISP mode, JR\_FROM\_EMOJIS has a variable score based upon the
number of Emojis at, or exceeding, the hit count.  In Manual mode,
<YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard SpamAssassin fashion.

- The Default() hit count is 1.

## check\_replyto\_emojis()

- This tests the Reply-To Name field for Unicode Emojis.
In Tag mode JR\_FROM\_EMOJIS, or <YOUR\_RULENAME>, is set to a callout value of
0.01.  In AutoISP mode, JR\_FROM\_EMOJIS has a variable score based upon the
number of Emojis at, or exceeding, the hit count.  In Manual mode,
<YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard SpamAssassin fashion.

- The Default() hit count is 1.

## useless\_utf\_check()

- This tests the Subject for useless UTF-8 characters and hits when the
defined count is reached.  In Tag mode JR\_SUBJ\_UTF\_MISUSE, or <YOUR\_RULENAME>,
is set to a callout value of 0.01.  In AutoISP mode, JR\_SUBJ\_UTF\_MISUSE has a
variable score based upon the number of these UTF characters at, or over, the
limit.

- In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE>
and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- The Default() hit count is 4.

## from\_lookalike\_unicode()

- This checks the From Name field for the presence of multiple Unicode
Alphabets.  Spammers use these "Look-Alike" characters for spoofing.  This
sets the maximum number of Alphabets that can appear here.  This is almost
always 1; a single Character Code Set.  This will detect most of the From
Name character spoofs.

- In Tag mode JR\_UNIBABBLE, or <YOUR\_RULENAME>, is set to a callout
value of 0.01.  In Manual mode JR\_UNIBABBLE, or <YOUR\_RULENAME>, may be
Scored and Described in standard SA fashion.

- In Tag mode JR\_UNIBABBLE, or <YOUR\_RULENAME>, is scored at a callout
value of 0.01.  In Manual mode JR\_UNIBABBLE, or <YOUR\_RULENAME>, may be
Scored and Described in standard SA fashion.   In Auto mode, JR\_UNIBABBLE
is scored variably, depending upon the amount over the defined threshold.

## subj\_lookalike\_unicode()

- This checks the email Subject for the presence of multiple Unicode
Alphabets.  Spammers use these "Look-Alike" characters for spoofing.  This
sets the maximum number of Alphabets that can appear here.  Usually a value
of 1 works, but some Some professionals and academia may want to set this
value to 2 to accomodate Math or Engineering Unicode symbols.

- In Tag mode JR\_SUBJ\_BABBLE, or <YOUR\_RULENAME>, is set to a callout
value of 0.01.  In Manual mode JR\_SUBJ\_BABBLE, or <YOUR\_RULENAME>, may be
Scored and Described in standard SA fashion.  In Auto mode, JR\_SUBJ\_BABBLE
is scored variably, depending upon the amount over the defined threshold.

## from\_enclosed\_chars()

- This checks the From Name field for the presence of Unicode Enclosed/
Encircled Latin characters.  These are often used in spam.

- In Tag mode JR\_FROM\_ENC\_CHARS, or <YOUR\_RULENAME>, is set to a
callout value of 0.01.  In Manual mode JR\_FROM\_ENC\_CHARS, or
<YOUR\_RULENAME>, may be Scored and Described in standard SA fashion.

> In Auto mode, JR\_FROM\_ENC\_CHARS is scored variably, depending upon the
> amount over the defined threshold.

## from\_enclosed\_chars()

- This checks the email Subject for the presence of Unicode Enclosed/
Encircled Latin characters.  These are often used in spam.

- In Tag mode JR\_SUBJ\_ENC\_CHARS, or <YOUR\_RULENAME>, is set to a
callout value of 0.01.  In Manual mode JR\_SUBJ\_ENC\_CHARS, or
<YOUR\_RULENAME>, may be Scored and Described in standard SA fashion.

> In Auto mode, JR\_SUBJ\_ENC\_CHARS is scored variably, depending upon the
> amount over the defined threshold.

## subject\_title\_case()

- This is a Subject header test that detects the presence of all Title Case
(Proper Case) words.  The rule, JR\_TITLECASE, is set with a fixed score in Auto
mode and a 0.01 callout value in Tag mode.  In Manual mode, <YOUR\_RULENAME>
is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard
SpamAssassin fashion.

- The number of words that must be in the Subject is a tunable value.  The
default value() is 4.

## check\_replyto\_length()

- This checks the length of the Reply-To field.  When the length is
excessive the rule, JR\_LONG\_REPLYTO, is set.  This is a fixed score in
Auto mode and a 0.01 callout value in Tag mode.  In Manual mode,
<YOUR\_RULENAME> is scored  with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard  SpamAssassin fashion.

- The number of \*characters\* that can appear in the Reply-To field is
tunable.  The default value() is 175.

## check\_cc\_public\_name()

- This is a Header test of the CC field.  If a valid Name cannot be found
and the number of CC Email Addresses hits a tunable number, then the rule,
JR\_CC\_PUB\_NONAME, is set (In Auto mode).  In Manual mode the rule's name, the
description, and the score can be set as needed.  In Tag mode, the score is
fixed at a 0.01 callout level.

- The default() number of CC Email Addresses that must be present is 25.

- Public Emails are not necessarily FREEMAILs.  These Email addresses
include common Network/Carrier addresses, like "verizon.net" or "comcast.net".
These represent the top 100 or so Email systems, world-wide.

## check\_to\_public\_name()

- This is a Header test of the TO field.  If a valid Name cannot be found
and the number of TO Email Addresses hits a tunable number, then the rule,
JR\_TO\_PUB\_NONAME, is set (In Auto mode).  In Manual mode the rule's name, the
description, and the score can be set as needed.  In Tag mode, the score is
fixed at a 0.01 callout level.

- The default() number of TO Email Addresses that must be present is 50.

- Public Emails are not necessarily FREEMAILs.  These Email addresses
include common Network/Carrier addresses, like "verizon.net" or "comcast.net".
These represent the top 100 or so Email systems, world-wide.

## check\_pub\_shorturls()

- This is a test of URIs in the message body, looking for URL Shortener
services.  These services are grouped as Public (bit.ly, etc.) and Private
(wpo.st, etc.).  When a match is found, the rule JR\_PUB\_SHORTURL (in Auto
 mode) is set and the scoring of the rule is variable depending upon the count
 of Public URL Shorteners found above the defined limit, which is 1 by default.

- In Tag mode, the rule  The rule, JR\_PUB\_SHORTURL or <YOUR\_RULENAME>
 is set to a callout value of 0.01.  In Manual mode, the rule can be <NAMED>,
 <DESCRIBED> and <SCORED> in standard SpamAssassin fashion.

## check\_priv\_shorturls()

- This is a test of URIs in the message body, looking for URL Shortener
services.  These services are grouped as Public (bit.ly, etc.) and Private
(wpo.st, etc.).  When a match is found, the rule JR\_PRIV\_SHORTURL (in Auto
 mode) is set and the scoring of the rule is variable depending upon the count
 of Private URL Shorteners found above the defined limit, which is 1 by default.

- In Tag mode, the rule  The rule, JR\_PRIV\_SHORTURL or <YOUR\_RULENAME>
is set to a callout value of 0.01.  In Manual mode, the rule can be <NAMED>,
<DESCRIBED>, and <SCORED> in standard SpamAssassin fashion.

## check\_honorifics()

- This tests the From Name field for honorifics (Mr./Mrs./Miss/Barrister,
etc) and if found, the rule JR\_HONORIFICS, is set (Auto Mode).  This is a
fixed score in Auto mode and a 0.01 callout value in Tag mode.

- In Manual mode, <YOUR\_RULENAME> is scored  with whatever <YOUR\_SCORE>
and <YOUR\_DESCRIBE>, in the standard  SpamAssassin fashion.

## from\_in\_subject()

- This tests looks for the presence of the From Name field in the Subject.
If so, rule JR\_SUBJ\_HAS\_FROM\_NAME is set in Auto Mode and scored at a fixed
level.  In Tag mode, JR\_SUBJ\_HAS\_FROM\_NAME or <YOUR\_RULENAME> is scored at a
callout value of 0.01.

- In Manual mode, JR\_SUBJ\_HAS\_FROM\_NAME or <YOUR\_RULENAME> is scored and
described in the standard SA fasion.

## first\_name\_basis()

- This tests the From Name field for the use of a single First Name.
The match includes some first name variants, like "Mr. Jared", "Jared at
home", or First Name and Last Initial.  In Auto mode, the rule
JR\_FRM\_FRSTNAME is scored with a fixed score.

- In Tag mode, JR\_FRM\_FRSTNAME or <YOUR\_RULENAME> is set and scored
with a callout value of 0.01.

- In Manual mode, you many name this rule whatever you like and
<YOUR\_RULENAME> is scored and described in standard SA fashion.

## from\_no\_vowels()

- This tests the From Name for gibberish.  If there are space-separated
 word characters but no vowels present, the rule is matched.  The rule
 JR\_FROM\_NO\_VOWEL is scored at a fixed rate in Auto mode and scored with a
 callout value of 0.01 in Tag mode.

- In Manual mode, JR\_FROM\_NO\_VOWEL or <YOUR\_RULENAME> is scored and
described in the standard SA fasion.

## check\_admin\_fraud()

- This is a Subject header test for Admin Fraud \[Account Disabled, Over
Quota, etc.\] messages.  Also included are Subject header tests for the old
SOBIG and SOBER worms.  In Auto mode, JR\_ADMIN\_FRAUD is set to a high watermark
value of ${chaos\_high}; one of two rules herein that score as such.

- In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule,
describe it, and score it as desired, in standard SA fashion.

## check\_admin\_fraud\_body()

- This is a Body test that looks for Admin Fraud \[Account Disabled, Quota
Exceeded, etc.\] messages.  This test is more expensive than standard Body
rules which are pre-compiled with RE2C.  It's not bad, but still something to
consider.

    In Auto mode, JR\_ADMIN\_BODY is set to a high watermark value of ${chaos\_high};
    one of two rules herein that score as such.

- In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule,
describe it, and score it in standard SA fashion.

## check\_for\_sendgrid()

- This tests all headers for the presence of Sendgrid. If found, the rule
JR\_HAS\_SENDGRID is scored appropriately, 0.35 \* ${chaos\_tag} and described:
"CHAOS.pm detection: Sendgrid in Headers"

- If Sendgrid headers are present, there is another test for their X-SG-EID
header.  If not present, the score returned is: ${chaos\_tag}.

## mailer\_check()

- Provides a lot of information about the sending system and the E-Mail
 format.  Rulenames herein are immutable.  In all modes of operation, scores
 are fixed at a callout level of 0.01 unless marked with an Asterisk.  Those
 rules are scored in Auto mode only.

- **X-Header Detections**

            JR_MAILER_BAT *         JR_SENDBLUE *                   JR_OUTLOOK_2003
            JR_MAILER_PHP *         JR_GEN_XMAILER *                JR_OUTLOOK_2007
            JR_CHILKAT *        JR_ATL_MAILER                       JR_OUTLOOK_2010
            JR_MAILKING *       JR_SWIFTMAILER *            JR_OUTLOOK_2013
            JR_VIRUS_MAILERS *  JR_OUTLOOK_EXPRESS *        JR_OUTLOOK_2016
        JR_CAMPAIGN_PRO *   JR_MAROPOST *                   JR_MAILCHIMP *
            JR_APPLE_DEVICE

- **PHP Script Detections**

- This checks for the presence of headers that indicate that the
 message was sent by a bad or exploited PHP script.  A single immutable
 rulename with a callout score is returned, unless in Auto mode:

- JR\_PHP\_SCRIPT

- **UTF-8 Checks**

- This checks the FROM, TO, REPLY-TO, and SUBJECT headers for Unicode
 Transformation Format headers, UTF-8.  Thie rulename is immutable and is
 scored with a callout value of 0.01 in all modes.  The rulenames returned
 by this Eval describe either Quoted-Printable or Base-64 encodings:

-
        JR\_SUBJ\_UTF8\_QP     JR\_SUBJ\_UTF8\_B64
        JR\_FROM\_UTF8\_QP     JR\_FROM\_UTF8\_B64
        JR\_TO\_UTF8\_QP       JR\_TO\_UTF8\_B64
        JR\_REPLY\_UTF8\_QP    JR\_REPLY\_UTF8\_B64

## id\_attachments()

- This is a check of the 'Content-Type' MIME headers for potentially bad attachments.  These include Archive, MS Office/Works, RTF, PDF, Boot Image, Executable Program, and HTML, file attachments.  These are immutable Callouts, and each have a score of 0.01.

        JR_ATTACH_ARCHIVE         JR_ATTACH_RTF
        JR_ATTACH_PDF             JR_ATTACH_BOOTIMG
        JR_ATTACH_MSOFFICE        JR_ATTACH_EXEC
        JR_ATTACH_OPENOFFICE      JR_ATTACH_HTML
        JR_ATTACH_RISK

- JR\_ATTACH\_RISK is rule that is also set if ANY of the above rules are matched.

- The following immutable rules are specific callouts for JPG, ZIP, and GZ files.

        JR_ATTACH_ZIP               JR_ATTACH_GZIP
        JR_ATTACH_JPEG              JR_ATTACH_IMAGE


- The callout rule, JR\_ATTACH\_IMAGE, is set when ANY (jpg,gif,png,bmp,etc.) common image attachment is detected.

- If an attachment filename is the same as the Message Subject, the rule JR\_SUBJ\_ATTACH\_NAME is set.  This is scored at a callout level of 0.01 except in Auto mode.

# MORE DOCUMENTATION

- See also &lt;https://spamassassin.apache.org/> and &lt;https://wiki.apache.org/spamassassin/> for more information.

- See this project's Wiki for more informaton: https://github.com/telecom2k3/CHAOS/wiki/

# SEE ALSO

- Mail::SpamAssassin::Conf(3)
- Mail::SpamAssassin::PerMsgStatus(3)
- Mail::SpamAssassin::Plugin

# BUGS

- While I do follow the SA-User's List, please do NOT report bugs there.
- If at all possible, please use the issue tracker at GitHub to report problems and request any additional features:  https://github.com/telecom2k3/CHAOS/issues
- You can also report the problem by E-Mail.  See the AUTHOR section for contact information.

# AUTHOR

- Jared Hall, <jared@jaredsec.com> or <telecom2k3@gmail.com>

# CAVEATS

- Tuorum Periculo: If an Eval rule provided in this plugin does not meet the requirements of you or your clients, please disable the rule and report the problem.  See the BUGS section for information regarding problem reporting.

- The author does NOT accept any liability whatever for YOUR use of this software. Use at your own risk!

# COPYRIGHT

- CHAOS.pm is distributed under the MIT License as described in the LICENSE file included.  Copyright (c) 2021 Jared Hall

# AVAILABILITY

- Visit the project's site for the latest updates: https://github.com/telecom2k3/CHAOS/
