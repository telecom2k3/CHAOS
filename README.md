# NAME

Mail::SpamAssassin::Plugin::CHAOS, Version 1.0.5

# SYNOPSIS

- Usage:

            loadplugin      Mail::SpamAssassin::Plugin::CHAOS               CHAOS.pm
                    header  JR_SUBJ_EMOJI           eval:check_for_emojis()
                    header  JR_FRAMED_WORDS         eval:framed_message_check()
                    header  JR_UNIBABBLE            eval:from_lookalike_unicode()
                    header  JR_TITLECASE            eval:subject_title_case()
                    ...


# DESCRIPTION

This is a SpamAssassin module that provides a variety of: Callouts, Handlers, And Object Scans (CHAOS).  To assist one's pursuit of Ordo Ab Chao, this SpamAssassin plugin provides over 20 unique Eval rules.

This plugin demonstrates SpamAssassin's relatively new (3.4) dynamic scoring capabilities:

        + Use PERL's advanced arithmetic functions.
        + Dynamic, Variable, and Conditional scoring.
        + Adaptive scoring (baseline reference).

This is a self-describing and self-scoring module.

## Adaptive Scoring Configuration

- The rules provided by thie module are self-scoring.  The scores are set to
a percentage of three values, the value at which mail is (1) Tagged as Spam,
(2) invokes Evasive Actions, and (3) Final Destinaltion/Silent Discard.
These values must be set in the .cf configuration file.

    For example, if a particular rule scores 4.5 on this mail system, the rule
    score would be something like: $score = $pms->{conf}->{chaos\_tag} \* 0.64.  If
    you want to increase the scores provided by this module, just increase these
    values.  Conversely, decreasing these values results in lower scores.

            Default Values
        --------------
            chaos_tag 7
            chaos_high 14
            chaos_max 28


- In a pure-play, basic SpamAssassin environment, try setting these all these
values to 5.

# METHODS

- This module DOES require configuration for the Adaptive Scoring to work properly in different environments.

- This plugin provides many Eval routines, called in standard fashion from local SpamAssassin ".cf" configuration files.

## check\_for\_brackets()

- Got 5 or more brackety-like characters?  This is a Subject header test
for Left and Right, Brackets, Braces, and Parens.  This includes Unicode
varients.  The total number of brackets is returned and the rule
JR\_HAS\_MANY\_BRACKETS is set.

- The rule's description will reflect the number of characters
matched: "CHAOS.pm dynamic score.  Count: $totalcount"

## check\_bracket\_balance()

- This is a Subject header test for Left and Right, Brackets, Braces, and
Parens.  This includes Unicode varients.  If there's a difference between
the numer of Left and Right brackets AND there are a total of 4 or more
bracket characters, the rule JR\_UNBALANCED\_BRACKETS is set.

- The rule's description will reflect the number of characters
matched: "CHAOS.pm dynamic score.  Count: $totalcount"

## subject\_title\_case()

- This is a Subject header test that detects the presence of all
Title Case (Proper Case) words.  The rule, JR\_TITLECASE, is set with a
fixed score of ${chaos\_tag} \* 0.28.

## check\_for\_emojis()

- This is a Subject header test that looks for the Unicode representations
of Emojis.  The rule's description will reflect the number of Emojis found:
"CHAOS.pm dynamic score.  Count: $totalcount"

- This rule, JR\_SUBJ\_EMOJI, has a variable score based upon the number of
Emojis found.

## from\_has\_emojis()

- This tests the FROM, REPLY-TO, and TO Name fields for the presence of
 unicode Emojis.  The rule's description will reflect the number of Emojis found:
"CHAOS.pm dynamic score.  Count: $totalcount"

- This check can return three rules: JR\_FROM\_EMOJI, JR\_TO\_EMOJI, JR\_REPLYTO\_EMOJI

## framed\_digit\_check()

- This is a Subject header test that looks for the presence of Framed /
Bracketed digits \[4\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants.  The rule's description
will reflect the number of Framed/Bracketed Digits found:
"CHAOS.pm dynamic score. Count: $framed"

- This score is variable, based upon the number of framed-digits detected.
Using the defaults, a single match is scored at: $score = ${chaos\_tag} \* 0.35
while multiple matches are scored at: $score = ${chaos\_tag} \* 0.46 \* $framed

## framed\_message\_check()

- This is a Subject header test that looks for the presence of Framed /
Bracketed words \[URGENT\].  All standard Parens, Brackets, and Braces are
supported, along with Unicode variants!  The rule's description
will reflect the number of instances found:
"CHAOS.pm dynamic score. Count: $framed"

- This score is variable, based upon the number of matches.

## useless\_utf\_check()

- This is a Subject header test that looks for the presence of useless
Unicode filler characters: "CHAOS.pm dynamic score. Count: $totalcount"

- This score is variable, based upon the number of framed-digits detected.

## check\_for\_sendgrid()

- This tests all headers for the presence of Sendgrid. If found, the rule
JR\_HAS\_SENDGRID is scored appropriately, 0.35 \* ${chaos\_tag} and described:
"CHAOS.pm detection: Sendgrid in Headers"

- If Sendgrid headers are present, there is another test for their X-SG-EID
header.  If not present, the score returned is: ${chaos\_tag}.

## check\_honorifics()

- This tests the From Name field for honorifics; Mr./Mrs./Miss/Barrister/etc.
If found, rule JR\_HONORIFICS is set and scored at: 0.33 \* ${chaos\_tag}.

## from\_in\_subject()

- This tests looks for the presence of the From Name field in the Subject.
If so, rule JR\_SUBJ\_HAS\_FROM\_NAME is set, scored at: 0.6 \* ${chaos\_tag}.

## mailer\_check()

- Picks up the usual bad crappy mailers and services.  Rules returned
are JR\_MAILER\_BAT, JR\_MAILER\_PHP, JR\_CHILKAT, JR\_MAILKING, JR\_SENDBLUE,
JR\_APPLE\_XMAIL, JR\_GEN\_XMAILER, JR\_CAMPAIGN\_PRO, and JR\_SWIFTMAILER.  Scores
vary depending upon the mailer used.

## apple\_detect()

- Detects the Apple-Mail MIME boundary set by Apple in their e-mail applications.  This is a simple callout, and JR\_APPLE\_MIME merely scores at a value of 0.01.

## check\_utf\_headers()

- This tests for the presence of UTF-8 character codesets in the Subject, From, To and Reply-To fields.  The rules: JR\_UTF8\_SUBJ, JR\_UTF8\_FROM, R\_UTF8\_TO, and JR\_UTF8\_REPLYTO are callouts, set to a score of 0.01.

## check\_replyto\_length()

- This checks the length of the Reply-To field.  When the length is excessive the rule, JR\_LONG\_REPLYTO, is set and scored at 0.37 \* ${chaos\_tag}.

## check\_admin\_fraud()

- This is a Subject header test for Admin Fraud \[Account Disabled\] messages.  Also included are Subject header tests for the old SOBIG and SOBER worms.  JR\_ADMIN\_FRAUD is set to a value of ${chaos\_high}.

## check\_admin\_fraud\_body()

- This is a Body test that looks for Admin Fraud \[Account Disabled, Quota Exceeded\] messages.  This test is more expensive than standard Body rules which are pre-compiled with RE2C.  It's not bad, but still something to consider.  JR\_ADMIN\_BODY is set to a value of ${chaos\_high} if a match is detected.

## from\_lookalike\_unicode()

- This is a Header test of the From Name field.  This checks for Unicode "Look-Alike" characters used by Spammers to bypass standard eval tests. The scoring of the rule, JR\_UNIBABBLE, is logarithmic and based upon the number of Unicode characters found.

## check\_for\_url\_shorteners()

- This is a test of URIs in the message body, looking for URL Shortener services.  These services are grouped as Public (bit.ly, etc.) and Private (wpo.st, etc.).  The scoring of the rule, JR\_PUBLIC\_SHORTURL, is linear: ${chaos\_tag} \* 0.25 \* $pubcount + $pubcount \* 1.5.  The rule, JR\_PRIVATE\_SHORTURL is a callout for your use in Meta rules as needed.  It has a fixed score of 0.01.  For both rules, the Description contains a count of the number of Short URL links found.

## check\_php\_script()

- This is a check for miscreant X-PHP-Originating-Script headers.  The rule JR\_PHP\_SCRIPT is set when a header match is detected.  Scores vary, depending upon the PHP script used to send the message.

## id\_attachments()

- This is a check of the 'Content-Type' MIME headers for potentially bad attachments.  These include Archive, MS Office/Works, RTF, PDF, Boot Image, Executable Program, and HTML, file attachments.  These are Callouts, and each have a score of 0.01.

        + JR_ATTACH_ARCHIVE         + JR_ATTACH_RTF
        + JR_ATTACH_PDF             + JR_ATTACH_BOOTIMG
        + JR_ATTACH_MSOFFICE        + JR_ATTACH_EXEC
        + JR_ATTACH_OPENOFFICE      + JR_ATTACH_HTML
        + JR_ATTACH_RISK

- JR\_ATTACH\_RISK is rule that is also set if ANY (OR) of the above rules are matched.  Useful in conjunction with Body phrase checks for "Open Me", "Click This" schemes.

- The following rules are specific callouts for JPG, ZIP, and GZ files.  The callout rule, JR\_ATTACH\_IMAGE, is set when ANY common image attachment is detected.

        + JR_ATTACH_ZIP             + JR_ATTACH_GZIP
        + JR_ATTACH_JPEG            + JR_ATTACH_IMAGE

- There is one scoring rule that matches if an attachment filename equals the message's Subject.  This is scored at 0.58 \* {chaos\_tag}.

        + JR_SUBJ_ATTACH_NAME


## first\_name\_basis()

- This tests the From Name field for the use of a single First Name.  The match includes some first name variants, like "Mr. Jared", "Jared at home", or First Name and Last Initial.  If found, rule JR\_FRM\_FRSTNAME is set and scored at: 0.3 \* ${chaos\_tag}.

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
