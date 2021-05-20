# NAME

Mail::SpamAssassin::Plugin::CHAOS

        Version: 1.1.2
    Name: "A Little Whacked"

# SYNOPSIS

- Usage:

            ifplugin Mail::SpamAssassin::Plugin::CHAOS
                    chaos_mode Manual
                    header          JR_UNIBABBLE        eval:from_lookalike_unicode()
                    describe        JR_UNIBABBLE        From Name Character Spoofs
                    score           JR_UNIBABBLE        3.0
                    ...
                    header          JR_SUBJ_EMOJI       eval:check_for_emojis()
                    header          JR_FRAMED_WORDS     eval:framed_message_check()
                    header          JR_TITLECASE        eval:subject_title_case()
                    ...
            endif



# DESCRIPTION

This is a SpamAssassin module that provides a variety of: Callouts, Handlers, And Object Scans (CHAOS).  To assist one's pursuit of Ordo Ab Chao, this SpamAssassin plugin provides over 20 unique Eval rules.  It does a lot of counting.

This plugin demonstrates SpamAssassin's relatively new (3.4) dynamic scoring capabilities:

        + Use PERL's advanced arithmetic functions.
        + Dynamic, Variable, and Conditional scoring.
        + Adaptive scoring (baseline reference).

This module can operate in the following modes:

- "Tag" mode sets the scores for all rules produced to a callout level of 0.01.  You can add or change rulenames using these Evals, but the description and soore remain fixed.  This is useful when first integrating this module into an existing SA system.  This is the default mode of operation.
- "Manual" mode allows you, the user, to set the Name, Describe, and Score fields for each Eval; in traditional SA fashion.  A couple of notes about Manual mode: (1) If a DESCRIBE field is not set, the module's Eval routing will provide one.  (2) If a SCORE is not set, the Eval routine will return a callout value of 0.01 for the rule.
- "AutoISP" mode allows you to quickly scale the rules to ranges suitable for ISP/ESP use.

## Adaptive Scoring Configuration

- The rules provided by thie module are auto-scoring.  The scores are set to
a percentage of the value at which mail is Tagged as Spam.
This value is set in the .cf configuration file.

    For example, if a particular rule scores 4.5 on this mail system, the rule
    score would be something like: $score = $pms->{conf}->{chaos\_tag} \* 0.64. 
    Changing this value will increase or decrease ALL scores provided by
    this module in Auto mode.

            Default Values
            --------------
            chaos_tag 7


- In a pure-play, basic SpamAssassin environment, try setting this to 4.

# METHODS

- This plugin provides many Eval routines, called in standard fashion from local SpamAssassin ".cf" configuration files.
=item  Most of these Eval routines can be passed a COUNT value in the parenthesis ().

## check\_subj\_brackets()

Default()=7

- This is a Subject header test for Left and Right, Brackets, Braces, Parenthesis and their Unicode varients.  These are sometimes called Set, Framing, or Grouping Characters.  In Tag mode, JR\_SUBJ\_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR\_SUBJ\_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR\_SUBJ\_BRACKETS or <YOUR\_RULENAME> is appended with an "\_$count" whose score is 0.01. Example: YOUR\_RULENAME\_3.

## check\_from\_brackets()

Default()=5

- This is a test of the From Name field for Left, Right, Brackets, Braces, Parenthesis and their Unicode varients.  In Tag mode, JR\_FROM\_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR\_FROM\_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR\_FROM\_BRACKETS or <YOUR\_RULENAME> is appended with an "\_$count" whose score is 0.01. Example: YOUR\_RULENAME\_3.

## framed\_message\_check()

Default()=1

- This is a Subject header test that looks for the presence of Framed /
Bracketed words, lie: \[URGENT\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants!  In The Auto and Tag modes, the rule's
description will reflect the number of instances found.

- In Auto mode this score is variable, based upon the number of matches at or above
the defined count.  The default() count is 1.  When running in Tag mode, the score is
set to a callout level of 0.01.

## framed\_digit\_check()

Default()=2

- This is a Subject header test that looks for the presence of Framed /
Bracketed digits \[4\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants.  In The Auto and Tag modes, the
rule's description will reflect the number of instances found.

- In Auto mode, the score is variable, based upon the number of framed
digits at, or over, the defined count.  The default() count is 2.

## check\_for\_emojis()

Default()=3

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

Default()=1

- This is a test of the From Name field that looks for Unicode Emojis.
In Tag mode JR\_FROM\_EMOJIS, or <YOUR\_RULENAME>, is set to a callout value of
0.01.  In AutoISP mode, JR\_FROM\_EMOJIS has a variable score based upon the
number of Emojis at, or exceeding, the hit count.  In Manual mode,
<YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard SpamAssassin fashion.

## check\_replyto\_emojis()

Default()=1

- This tests the Reply-To Name field for Unicode Emojis.
In Tag mode JR\_FROM\_EMOJIS, or <YOUR\_RULENAME>, is set to a callout value of
0.01.  In AutoISP mode, JR\_FROM\_EMOJIS has a variable score based upon the
number of Emojis at, or exceeding, the hit count.  In Manual mode,
<YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard SpamAssassin fashion.

## useless\_utf\_check()

Default()=4

- This tests the Subject for useless UTF-8 characters and hits when the
defined count is reached.  In Tag mode JR\_SUBJ\_UTF\_MISUSE, or <YOUR\_RULENAME>,
is set to a callout value of 0.01.  In AutoISP mode, JR\_SUBJ\_UTF\_MISUSE has a
variable score based upon the number of these UTF characters at, or over, the
limit.

- In Manual mode, <YOUR\_RULENAME> is scored with whatever <YOUR\_SCORE>
and <YOUR\_DESCRIBE>, in the standard SpamAssassin fashion.

- The Default() hit count is 4.

## from\_lookalike\_unicode()

Default()=1

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

- Countries with LATIN-2 alphabets (ISO 8859-2/8859-3) should set
the count to 2: from\_lookalike\_unicode(2).

## subj\_lookalike\_unicode()

Default()=1

- This checks the email Subject for the presence of multiple Unicode
Alphabets.  Spammers use these "Look-Alike" characters for spoofing.  This
sets the maximum number of Alphabets that can appear here.  Usually a value
of 1 works, but some Some professionals and academia may want to set this
value to 2 to accomodate Math or Engineering Unicode symbols.

- In Tag mode JR\_SUBJ\_BABBLE, or <YOUR\_RULENAME>, is set to a callout
value of 0.01.  In Manual mode JR\_SUBJ\_BABBLE, or <YOUR\_RULENAME>, may be
Scored and Described in standard SA fashion.  In Auto mode, JR\_SUBJ\_BABBLE
is scored variably, depending upon the amount over the defined threshold.

- Countries with LATIN-2 alphabets (ISO 8859-2/8859-3) should set
the count to 2: subj\_lookalike\_unicode(2).

## from\_enclosed\_chars()

Default()=3

- This checks the From Name field for the presence of Unicode Enclosed/
Encircled and Mathematical Latin characters.  These are often used in spam.

- In Tag mode JR\_FROM\_ENC\_CHARS, or <YOUR\_RULENAME>, is set to a
 callout value of 0.01.  In Auto mode, JR\_FROM\_ENC\_CHARS is scored variably,
 depending upon the amount over the defined threshold.

- In Manual mode JR\_FROM\_ENC\_CHARS, or <YOUR\_RULENAME>, may be Scored and
 Described in standard SA fashion.

## subj\_enclosed\_chars()

Default()=3

- This checks the email Subject for the presence of Unicode Enclosed/
Encircled Latin characters.  These are often used in spam.

- In Tag mode JR\_SUBJ\_ENC\_CHARS, or <YOUR\_RULENAME>, is set to a
 callout value of 0.01.  In Auto mode, JR\_SUBJ\_ENC\_CHARS is scored variably,
 depending upon the amount over the defined threshold.

- In Manual mode JR\_SUBJ\_ENC\_CHARS, or <YOUR\_RULENAME>, may be Scored
 and Described in standard SA fashion.

## subject\_title\_case()

Default()=4

- This is a Subject header test that detects the presence of all Title Case
(Proper Case) words.  The rule, JR\_TITLECASE, is set with a fixed score in Auto
mode and a 0.01 callout value in Tag mode.  In Manual mode, <YOUR\_RULENAME>
is scored with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>, in the standard
SpamAssassin fashion.

- The number of words that must be in the Subject is a tunable value.  The
default value() is 4.

## check\_replyto\_length()

Default()=175

- This checks the length of the Reply-To field.  When the length is
excessive the rule, JR\_LONG\_REPLYTO, is set.  This is a fixed score in
Auto mode and a 0.01 callout value in Tag mode.  In Manual mode,
<YOUR\_RULENAME> is scored  with whatever <YOUR\_SCORE> and <YOUR\_DESCRIBE>,
in the standard  SpamAssassin fashion.

- The number of \*characters\* that can appear in the Reply-To field is
tunable.  The default value() is 175.

## check\_cc\_public\_name()

Default()=25

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

Default()=50

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

Default()=1

- This is a test of URIs in the message body, looking for URL Shortener
services.  These services are grouped as Public (bit.ly, etc.) and Private
(wpo.st, etc.).  When a match is found, the rule JR\_PUB\_SHORTURL (in Auto
 mode) is set and the scoring of the rule is variable depending upon the count
 of Public URL Shorteners found above the defined limit, which is 1 by default.

- In Tag mode, the rule  The rule, JR\_PUB\_SHORTURL or <YOUR\_RULENAME>
 is set to a callout value of 0.01.  In Manual mode, the rule can be <NAMED>,
 <DESCRIBED> and <SCORED> in standard SpamAssassin fashion.

## check\_priv\_shorturls()

Default()=1

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
SOBIG and SOBER worms.

- In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule,
describe it, and score it as desired, in standard SA fashion.

## check\_admin\_fraud\_body()

- This is a Body test that looks for Admin Fraud \[Account Disabled, Quota
Exceeded, etc.\] messages.  This test is more expensive than standard Body
rules which are pre-compiled with RE2C.  It's not bad, but still something to
consider.

    In Auto mode, JR\_ADMIN\_BODY is set to a high watermark value of ${chaos\_tag}.

- In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule,
describe it, and score it in standard SA fashion.

## check\_email\_greets()

- This is a Body test that looks for common phrases and greetings using
the User-Part of the E-Mail address.

- In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule,
describe it, and score it in standard SA fashion.

## mailer\_check()

- Provides a lot of information about the sending system and the E-Mail
 format.  Rulenames herein are immutable.  In all modes of operation, scores
 are fixed at a callout level of 0.01 unless marked with an Asterisk.  Those
 rules are scored in Auto mode only.

- **X-Header Detections**

            JR_MAILER_BAT *     JR_SENDBLUE *           JR_OUTLOOK_2003
            JR_MAILER_PHP *     JR_GEN_XMAILER *        JR_OUTLOOK_2007
            JR_CHILKAT *        JR_ATL_MAILER           JR_OUTLOOK_2010
            JR_MAILKING *       JR_SWIFTMAILER *        JR_OUTLOOK_2013
            JR_VIRUS_MAILERS *  JR_OUTLOOK_EXPRESS *    JR_OUTLOOK_2016
            JR_CAMPAIGN_PRO *   JR_MAROPOST *           JR_MAILCHIMP *
            JR_APPLE_DEVICE     JR_CCONTACT             JR_SAILTHRU
            JR_FACEBOOK         JR_ZOHO                 JR_CHEETAH
            JR_XYZMAILER        JR_BLUESTREAK           JR_NEOLANE
            JR_ORACLE_XPRESS    JR_ESPUTNIK             JR_ZIMBRA
            JR_BRONTO *         JR_MIMELITE             JR_MSGSEND
            JR_MAILGUN          JR_COLDFUSION           JR_163_HMAIL
            JR_CREATESEND       JR_WHATCOUNTS           JR_MAILSENDER *
            JR_SENDY            JR_ATMAIL               JR_ASPNET *
            JR_MS_CDO           JR_PLACEWISE            JR_MARSHALL
            JR_MAILBEE          JR_ECP_MAIL             JR_PHP7_MAIL
            JR_AOL_WEBMAIL      JR_IBM_TRAVELER         JR_KEYS_MAIL
            JR_NODEMAILER *     JR_REACHMAIL *          JR_SAP_WEAVER
            JR_FB_MTA           JR_DMDROID              JR_MARSHALL
            JR_OPEN_XCHANGE     JR_FOXMAIL              JR_CLAWS_MAIL
            JR_FISHBOWL


- **PHP Script Detections**

    This checks for the presence of headers that indicate that the message was sent by a bad or exploited PHP script.  A single immutable rulename with a callout score is returned, unless in Auto mode:

               JR_PHP_SCRIPT


- **UTF-8 Checks**

- This checks the FROM, TO, REPLY-TO, and SUBJECT headers for Unicode
 Transformation Format headers, UTF-8.  Thie rulename is immutable and is
 scored with a callout value of 0.01 in all modes.  The rulenames returned
 by this Eval describe either Quoted-Printable or Base-64 encodings:

            JR_SUBJ_UTF8_QP     JR_SUBJ_UTF8_B64
            JR_FROM_UTF8_QP     JR_FROM_UTF8_B64
            JR_TO_UTF8_QP       JR_TO_UTF8_B64
            JR_REPLY_UTF8_QP    JR_REPLY_UTF8_B64

- **User-Agent Checks**

- This checks for the presence of a User-Agent header and tags
 agents with callout values only:

            JR_ROUNDCUBE        JR_HORDE
            JR_THUNDERBIRD      JR_UNK_USR_AGENT
            JR_ALPINE           JR_MAC_OUTLOOK
            JR_MUTT             JR_EMCLIENT
            JR_ANDROID          JR_SQUIRRELMAIL
            JR_DADDYMAIL        JR_KMAIL
            JR_REDCAPPI

- **Miscellaneous Checks**

- Various checks for headers that indicate a bad message.  A variety of Mailchimp sanity checks are performed.  JR\_EXCHANGE is a callout rule set when Microsoft Exchange Server headers are detected.  Many Microsoft Exchange header sanity checks are also performed.  JR\_DUP\_HDRS hits whenever multiple IDENTICAL header lines appear in a message.  There are also tests, JR\_MULTI\_HDRS, for headers that should never appear more than once.  There are also checks for headers that shouldn't appear in the presence of other headers.

            JR_BOGUS_HEADERS *      JR_BAD_CHIMP *
            JR_X_BEENTHERE *        JR_X_SENTBY *
            JR_EXCHANGE             JR_EXCHANGE_AUTH *
            JR_EXCH_BAD_AUTH *      JR_EXCH_ATTACH *
            JR_EXCHANGE_TYPE *      JR_X_UNVERIFIED *
            JR_DUP_HDRS *           JR_MULTI_HDRS *
            JR_PRI_MULTI *          JR_BULK *
            JR_SGRID_FWD *          JR_SGRID_DIRECT *

- All rules are callout values unless marked with an asterisk (\*).  These are scored at various fixed rates when in Auto mode.

- JR\_SGRID\_FWD and JR\_SGRID\_DIRECT reflect the presence of SendGrid mailer information.  If SendGrid headers are wrapped up in another container, like a References header, JR\_SGRID\_FWD is set.  In Auto mode, this is scored lower than the DIRECT rule which is set for direct emails from SendGrid, SendGrid partner companies, or the SendGrid API.

## id\_attachments()

- This is a check of the 'Content-Type' MIME headers for potentially bad attachments.  These include Archive, MS Office/Works, RTF, PDF, Boot Image, Executable Program, and HTML, file attachments.  These are immutable Callouts, and each have a score of 0.01.

        JR_ATTACH_ARCHIVE         JR_ATTACH_RTF
        JR_ATTACH_PDF             JR_ATTACH_BOOTIMG
        JR_ATTACH_MSOFFICE        JR_ATTACH_EXEC
        JR_ATTACH_OPENOFFICE      JR_ATTACH_HTML
        JR_ATTACH_RISK

- JR\_ATTACH\_RISK is rule that is also set if ANY of the above rules are matched.

- The following immutable rules are specific callouts for JPG, ZIP, CAB, and GZ files.

        JR_ATTACH_ZIP               JR_ATTACH_GZIP
        JR_ATTACH_JPEG              JR_ATTACH_CAB
        JR_ATTACH_IMAGE


- The callout rule, JR\_ATTACH\_IMAGE, is set when ANY (jpg,gif,png,bmp,etc.) common image attachment is detected.

- If an attachment filename is the same as the Message Subject, the rule JR\_SUBJ\_ATTACH\_NAME is set.  This is scored at a callout level of 0.01 except in Auto mode.

# PREREQUISITES

- PERL version 5.18, 5.22 or later
- SpamAssassin 3.4.2 or later with its standard PERL libraries

# INSTALLATION

- Copy the files, CHAOS.pre, CHAOS.cf, and CHAOS.pm to your SpamAssassin system folder.  This is usually /etc/spamassassin or /etc/mail/spamassassin.
- Edit/Change the CHAOS.cf file to your liking.
- If running with a Policy Daemon like Amavis, Policyd, MIMEDefang, etc., make sure that you restart that after installation or after making any changes.

# DIAGNOSTICS

- CHAOS.pm supports versioning and can provide additonal details about your SpamAssassin configuration:
-
        perl /$PATH\_TO/CHAOS.pm \[-v, --version\]  # CHAOS.pm, PERL, SA Version
        perl /$PATH\_TO/CHAOS.pm \[-V, --verbose\]  # Above + PERL libraries for SA
        perl /$PATH\_TO/CHAOS.pm \[-VV, --very\]    # Above + SA physical file paths

# MORE DOCUMENTATION

- See also &lt;https://spamassassin.apache.org/> and &lt;https://wiki.apache.org/spamassassin/> for more information.

- See this project's Wiki for more information: https://github.com/telecom2k3/CHAOS/wiki/

# SEE ALSO

- Mail::SpamAssassin::Conf(3)
- Mail::SpamAssassin::PerMsgStatus(3)
- Mail::SpamAssassin::Plugin

# BUGS

- While I do follow SA-User's, please do NOT report bugs there; I'm not glued-in to that list.
- If you are uncomfortable with Github problem reporting, you can always report problems by E-Mail.  See the AUTHOR section below for contact information.

# AUTHOR

- Jared Hall, <jared@jaredsec.com> or <telecom2k3@gmail.com>

# CAVEATS

- The author does NOT accept any liability for YOUR use of this software. If a particular Eval rule herein does not meet your requirements please disable (comment out) the rule and report the problem.  See the BUGS section for information regarding problem reporting.

# COPYRIGHT

- CHAOS.pm is distributed under the MIT License as described in the LICENSE file included.  Copyright (c) 2021 Jared Hall

# AVAILABILITY

- Visit the project's site for the latest updates: https://github.com/telecom2k3/CHAOS/

