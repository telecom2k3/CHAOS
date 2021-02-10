package Mail::SpamAssassin::Plugin::CHAOS;

use Mail::SpamAssassin::Plugin;
use Mail::SpamAssassin::PerMsgStatus;
use Mail::SpamAssassin::Message::Node qw( find_parts );
# use Data::Dumper;
use warnings;
use vars qw(@ISA);
our @ISA = qw(Mail::SpamAssassin::Plugin);

# I tag spam at a score of 7, Quarantine and send a Bounce at 14, and
# just silently Quarantine at 28.  ADJUST THESE AS NEEDED.  For example,
# in a pure-play SpamAssassin environment, set all these values to 5.
# The scores for all rules set by this plugin are based upon these values.
# 
# You probably don't need to change anything else.  But if you troll the
# code and make improvements, please let me know.  Thanks.
########################################################################
  

=pod
 
=head1 NAME

Mail::SpamAssassin::Plugin::CHAOS, Version 1.0.5

=head1 SYNOPSIS

=over

=item  Usage:

	loadplugin 	Mail::SpamAssassin::Plugin::CHAOS	 	CHAOS.pm
		header	JR_SUBJ_EMOJI		eval:check_for_emojis()
		header  JR_FRAMED_WORDS		eval:framed_message_check()
		header	JR_UNIBABBLE		eval:from_lookalike_unicode()
		header  JR_TITLECASE		eval:subject_title_case()
		...
		
=back

=head1 DESCRIPTION
 
This is a SpamAssassin module that provides a variety of: Callouts, Handlers, And Object Scans (CHAOS).  To assist one's pursuit of Ordo Ab Chao, this SpamAssassin plugin provides over 20 unique Eval rules.


This plugin demonstrates SpamAssassin's relatively new (3.4) dynamic scoring capabilities:

	+ Use PERL's advanced arithmetic functions.
	+ Dynamic, Variable, and Conditional scoring.
	+ Adaptive scoring (baseline reference).

This is a self-describing and self-scoring module. 

=head2  Adaptive Scoring Configuration

=over

=item

The rules provided by thie module are self-scoring.  The scores are set to
a percentage of three values, the value at which mail is (1) Tagged as Spam,
(2) invokes Evasive Actions, and (3) Final Destinaltion/Silent Discard. 
These values must be set in the .cf configuration file.

For example, if a particular rule scores 4.5 on this mail system, the rule
score would be something like: $score = $pms->{conf}->{chaos_tag} * 0.64.  If
you want to increase the scores provided by this module, just increase these
values.  Conversely, decreasing these values results in lower scores. 

	Default Values
    --------------
	chaos_tag 7
	chaos_high 14
	chaos_max 28
	
=item  

In a pure-play, basic SpamAssassin environment, try setting these all these
values to 5.
	
=back

=cut

=head1 METHODS

=over 5

=item  This module DOES require configuration for the Adaptive Scoring to work properly in different environments.

=back

=over 5

=item  This plugin provides many Eval routines, called in standard fashion from local SpamAssassin ".cf" configuration files.

=back

=cut


# I'm defining some Globals here.  
#################################

our $JRbody = "";
our $count = 0;
our $jr_line1 = "\xC7\xC7\xC7\xC7";
our $jr_line2 = "\xC7\xC7\xC7\xC7";
our $jr_line3 = "\xC7\xC7\xC7\xC7";
our $jr_line4 = "\xC7\xC7\xC7\xC7";
our $jr_line5 = "\xC7\xC7\xC7\xC7";
our $jr_look1 = "\xC7\xC7\xC7\xC7";

# Note to self: Use "local $.." instead of "my $..." to make $.. available to
# other subroutines
#############################################################################


sub new {
    my ( $class, $mailsa ) = @_;

    # the usual perlobj boilerplate to create a subclass object
	# Does anybody ever change the ^ statement?  A Google search says no!
    $class = ref($class) || $class;
    my $self = $class->SUPER::new($mailsa);
    bless( $self, $class );
	$self->set_config($mailsa->{conf});
	
	# $SpamTagLevel = $pms->{conf}->{chaos_tag};
	# $EvasiveLevel = $pms->{conf}->{chaos_high};
	# $QuietDiscard = $pms->{conf}->{chaos_max};


    # then register an eval rule, if desired...
	# Yes please.  I'll register a lot of them...
    $self->register_eval_rule("check_for_brackets");
	$self->register_eval_rule("check_bracket_balance");
	$self->register_eval_rule("subject_title_case");
	$self->register_eval_rule("check_for_emojis");
	$self->register_eval_rule("from_to_has_emojis");
	$self->register_eval_rule("framed_digit_check");
	$self->register_eval_rule("framed_message_check");
	$self->register_eval_rule("useless_utf_check");
	$self->register_eval_rule("check_for_sendgrid");
	$self->register_eval_rule("apple_detect");
	$self->register_eval_rule("check_utf_headers");
	$self->register_eval_rule("check_apple_device");
	$self->register_eval_rule("check_admin_fraud");
	$self->register_eval_rule("check_admin_fraud_body");
	$self->register_eval_rule("mailer_check");
	$self->register_eval_rule("check_honorifics");
	$self->register_eval_rule("from_lookalike_unicode");
	$self->register_eval_rule("check_for_url_shorteners");
	$self->register_eval_rule("check_php_script");
	$self->register_eval_rule("check_replyto_length");
	$self->register_eval_rule("from_in_subject");
	$self->register_eval_rule("id_attachments");
	$self->register_eval_rule("first_name_basis");
    
    # and return the new plugin object
	#
	# Kerplunk.  Good luck, kid.
    return $self;
}

sub set_config {
    my ($self, $conf) = @_;
    my @cmds = ();
    push (@cmds, {
        setting => 'chaos_tag',
        default => 7,
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_NUMERIC,
    });
	push (@cmds, {
        setting => 'chaos_high',
        default => 14,
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_NUMERIC,
    });
	push (@cmds, {
        setting => 'chaos_max',
        default => 28,
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_NUMERIC,
    });
	
	$conf->{parser}->register_commands(\@cmds);
	

return();
}


=head2  check_for_brackets()

=over 5

=item Got 5 or more brackety-like characters?  This is a Subject header test
for Left and Right, Brackets, Braces, and Parens.  This includes Unicode
varients.  The total number of brackets is returned and the rule
JR_HAS_MANY_BRACKETS is set.  

=back

=over 5

=item  The rule's description will reflect the number of characters 
matched: "CHAOS.pm dynamic score.  Count: $totalcount"

=back

=cut

sub check_for_brackets {

    my ( $self, $pms, $max ) = @_;
    my $subject = $pms->get('Subject:raw');
    my $leftcount = () = $subject =~ /\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B/g;
    my $rightcount = () = $subject =~ /\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D/g;
    my $totalcount = $leftcount + $rightcount;
    my $set = 0;
	my $score = 0;
	
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 4;
	} 
	if ($totalcount > $max) {
		$score = $pms->{conf}->{chaos_tag} * 0.5 * ($totalcount / 4);
		my $rulename = "JR_HAS_MANY_BRACKETS";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score.  Count: $totalcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	}

return 0;
}


=head2  check_bracket_balance()

=over 5

=item  This is a Subject header test for Left and Right, Brackets, Braces, and 
Parens.  This includes Unicode varients.  If there's a difference between
the numer of Left and Right brackets AND there are a total of 4 or more 
bracket characters, the rule JR_UNBALANCED_BRACKETS is set. 

=back

=over 5

=item  The rule's description will reflect the number of characters 
matched: "CHAOS.pm dynamic score.  Count: $totalcount"

=back

=cut


sub check_bracket_balance {
    my ( $self, $pms, $max ) = @_;
    my $subject = $pms->get('Subject:raw');
    my $leftcount = () = $subject =~ /\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B/g;
    my $rightcount = () = $subject =~ /\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D/g;
    my $totalcount = $leftcount + $rightcount;
    my $set = 0;
	my $score = 0;
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 4;
	}
    if (($leftcount != $rightcount) && $totalcount >= $max) {
		$score = $pms->{conf}->{chaos_tag} * 0.7;
		my $rulename = "JR_UNBALANCED_BRACKETS";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count:  $totalcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "HEADER: ", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
    }
return 0;
}

=head2  subject_title_case()

=over 5

=item This is a Subject header test that detects the presence of all 
Title Case (Proper Case) words.  The rule, JR_TITLECASE, is set with a
fixed score of ${chaos_tag} * 0.28.

=back

=cut

sub subject_title_case {

    my ( $self, $pms, $max ) = @_;
    my $subject = $pms->get('Subject');
	$subject =~ s/[^[[:upper:][:lower:][:digit:]]]//g;
	my $wcount = 0;
	my $tcount = 0;
	my $ucount = 0;
	my $set = 0;
	my $score = 0;
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 4;
	}
	foreach my $word (split('\s+',$subject)) {
		$wcount++;
		if ( $word =~ /[[:upper:][:digit:]][[:upper:][:lower:][:digit:]]*?/g ) {
			$tcount++;
		}
		if ( $word =~ /[[:upper:]]+/g ) {
			$ucount++;
		}
	}

	if (( $tcount == $wcount ) && ( $tcount != $ucount ) && ( $wcount >= $max )) {

		$score = $pms->{conf}->{chaos_tag} * 0.28;
		my $rulename = "JR_TITLECASE";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Subject in Title Case";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	}

return 0;
}

=head2  check_for_emojis()

=over 5

=item  This is a Subject header test that looks for the Unicode representations
of Emojis.  The rule's description will reflect the number of Emojis found: 
"CHAOS.pm dynamic score.  Count: $totalcount"

=back

=over 5

=item  This rule, JR_SUBJ_EMOJI, has a variable score based upon the number of 
Emojis found.

=back

=cut


# There are thousands and thousands of Emojis.  This is not a complete list,
# but it should pick up most of them.
sub check_for_emojis {
	# https://www.utf8-chartable.de/unicode-utf8-table.pl
    my ( $self, $pms, $max ) = @_;
    my $subject1 = $pms->get('Subject');
	&emoji_hunt();
	
	# Using Global Vars defined as TypeDef UniCode.  Otherwise, have
	# problems passing UniCode Vars defined in sub-routines, like the
	# Unicode QR pre-defined query strings returned from &emoji_hunt.
	# Something about Private vars...
	my $emojis1 = () = $subject1 =~ /$jr_line1/g;
	my $emojis2 = () = $subject1 =~ /$jr_line2/g;
	my $emojis3 = () = $subject1 =~ /$jr_line3/g;
	my $emojis4 = () = $subject1 =~ /$jr_line4/g;
	my $emojis5 = () = $subject1 =~ /$jr_line5/g;
	my $totalcount = $emojis1 + $emojis2 + $emojis3 + $emojis4 + $emojis5;
    my $set = 0;
	my $score = 0;
	my $rulename = "JR_SUBJ_EMOJI";
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 1;
	}
    if ($totalcount >= $max) {
		$score = $pms->{conf}->{chaos_tag} * 0.2 * ($totalcount - $max) + ($totalcount - $max);
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $totalcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	# Re-init the QR variables with Unicode Type.
	$jr_line1 = "\xC7\xC7\xC7\xC7";
    $jr_line2 = "\xC7\xC7\xC7\xC7";
    $jr_line3 = "\xC7\xC7\xC7\xC7";
    $jr_line4 = "\xC7\xC7\xC7\xC7";
	$jr_line5 = "\xC7\xC7\xC7\xC7";
	
return 0;
}

=head2  from_has_emojis()

=over 5

=item  This tests the FROM, REPLY-TO, and TO Name fields for the presence of
 unicode Emojis.  The rule's description will reflect the number of Emojis found: 
"CHAOS.pm dynamic score.  Count: $totalcount"

=back

=over 5

=item  This check can return three rules: JR_FROM_EMOJI, JR_TO_EMOJI, JR_REPLYTO_EMOJI 

=back

=cut


# Yep.  Emojis in a From Name.  Good thing I use "Smiley Jared" versus
# "Pants-On-Fire Jared" or "Grumpy Jared".  Woe is me.
sub from_to_has_emojis {
	# https://www.utf8-chartable.de/unicode-utf8-table.pl
    my ( $self, $pms, $max ) = @_;
	my $from = $pms->get('From:name');
	my $toname = $pms->get('To:name');
	my $rpyname = $pms->get('Reply-To:name');
	&emoji_hunt();
	
	# Using Global Vars defined as TypeDef UniCode.  Otherwise, have
	# problems passing UniCode Vars defined in sub-routines, like the
	# Unicode QR pre-defined query strings returned from &emoji_hunt.
	# Something about Private vars...
	my $emojis1 = () = $from =~ /$jr_line1/i;
	my $emojis2 = () = $from =~ /$jr_line2/i;
	my $emojis3 = () = $from =~ /$jr_line3/i;
	my $emojis4 = () = $from =~ /$jr_line4/g;
	my $totalcount = $emojis1 + $emojis2 + $emojis3 + $emojis4;
	
	my $temojis1 = () = $toname =~ /$jr_line1/i;
	my $temojis2 = () = $toname =~ /$jr_line2/i;
	my $temojis3 = () = $toname =~ /$jr_line3/i;
	my $temojis4 = () = $toname =~ /$jr_line4/g;
	my $tocount = $temojis1 + $temojis2 + $temojis3 + $temojis4;
	
	my $rpyemojis1 = () = $rpyname =~ /$jr_line1/i;
	my $rpyemojis2 = () = $rpyname =~ /$jr_line2/i;
	my $rpyemojis3 = () = $rpyname =~ /$jr_line3/i;
	my $rpyemojis4 = () = $rpyname =~ /$jr_line4/g;
	my $rpycount = $rpyemojis1 + $rpyemojis2 + $rpyemojis3 + $rpyemojis4;
	
    my $set = 0;
	my $score = 0;
	my $rulename = "";
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 0;
	}

    if ($totalcount > $max) {
		$rulename = "JR_FROM_EMOJI";
		$score = $pms->{conf}->{chaos_tag} * 0.3 * ($totalcount - $max) + ($totalcount - $max);
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $totalcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	if ($tocount > $max) {
		$rulename = "JR_TO_EMOJI";
		$score = $pms->{conf}->{chaos_tag} * 0.3 * ($tocount - $max) + ($tocount - $max);
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $tocount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	if ($rpycount > $max) {
		$rulename = "JR_REPLYTO_EMOJI";
		$score = $pms->{conf}->{chaos_tag} * 0.3 * ($rpycount - $max) + ($rpycount - $max);
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $rpycount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	# Re-init the QR variables with Unicode Type.
	$jr_line1 = "\xC7\xC7\xC7\xC7";
    $jr_line2 = "\xC7\xC7\xC7\xC7";
    $jr_line3 = "\xC7\xC7\xC7\xC7";
    $jr_line4 = "\xC7\xC7\xC7\xC7";
	
return 0;
}

=head2  framed_digit_check()

=over 5

=item  This is a Subject header test that looks for the presence of Framed / 
Bracketed digits [4].  All standard Parens, Brackets, and Braces are 
supported, along with Unicode variants.  The rule's description 
will reflect the number of Framed/Bracketed Digits found: 
"CHAOS.pm dynamic score. Count: $framed"

=back

=over 5

=item  This score is variable, based upon the number of framed-digits detected.
Using the defaults, a single match is scored at: $score = ${chaos_tag} * 0.35
while multiple matches are scored at: $score = ${chaos_tag} * 0.46 * $framed

=back

=cut
 
sub framed_digit_check {
    my ( $self, $pms, $max ) = @_;
    my $subject = $pms->get('Subject');
	my $set = 0;
	my $score = 0;
	my $rulename = "JR_FRAMED_DIGITS";
	my @count = $subject =~ /((\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?[0-9]{1,2}\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D))/g;
	@count = grep defined, @count; 
	my $framed = ( scalar @count / 3 );
	my @utfcount = $subject =~ /((\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?(\xEF\xBC\x90|\xEF\xBC\x91|\xEF\xBC\x92|\xEF\xBC\x93|\xEF\xBC\x94|\xEF\xBC\x95|\xEF\xBC\x96|\xEF\xBC\x97|\xEF\xBC\x98|\xEF\xBC\x99|\xEF\xBD\xAD|\xEF\xBD\xAE|\xEF\xBE\x95|\xEF\xBE\x96){1,2}\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D))/g;
	@utfcount = grep defined, @utfcount; 
	my $utfframed = ( scalar @utfcount / 3 );
	$framed = $framed + $utfframed;
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 0;
	}
	
    $max++;
	if ( $framed == $max ) {
		$score = $pms->{conf}->{chaos_tag} * 0.35;
	} elsif ( $framed > $max ) {
		$score = $pms->{conf}->{chaos_tag} * 0.46 * $framed;
	}
	if ( $framed >= $max ) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $framed";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	 

return 0;
}


=head2  framed_message_check()

=over 5

=item  This is a Subject header test that looks for the presence of Framed / 
Bracketed words [URGENT].  All standard Parens, Brackets, and Braces are 
supported, along with Unicode variants!  The rule's description 
will reflect the number of instances found: 
"CHAOS.pm dynamic score. Count: $framed"

=back

=over 5  

=item  This score is variable, based upon the number of matches.

=back

=cut

sub framed_message_check {
    my ( $self, $pms ) = @_;
    my $subject = $pms->get('Subject');
	my @count = $subject =~ /(\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?(NOTICE|OCTOBER|WEBCAST|URGENT|DOWNLOAD|ACTION|PAYPAL|PROPERTY|GUIDE|LIVE|TOMORROW|NEW|WEBINAR|IVENTIUM|TODAY|ENGINEER|UPDATE|UPDATES|STATEMENT|INVOICE|PURCHASE|VIDEO|SURVEY|SALE|FWD|EST|YYT|CMD|PAYMENT\sSTATEMENT\sRECEIPT|ACTION\sREQUIRED|ACTION\sNEEDED|TRANSACTION\sREPORT\sAUTHORIZATION|ACCOUNT\sREVIEW|ACCOUNT\sALERT|CASH\sOFFER|PROCEED\sTO\sRESOLVE\sNOW|PAYMENT\sSTORE\sCONFIRMED|DETAILS\sABOUT|EXTERNAL\sSENDER|LAST\sCHANCE|FREE|IMPORTANT|IMPORTANT\sUPDATE|SUSPEND|PDT|EDT|IMPORTANT\sACTION|CST|CDT|REPORT\sINFORMATION|SST|AMAZON\sSTATEMENT\sREPORT|GMT\+[0-9]{1,2}|PST|EST|NEWS\sSTATEMENT\sREPORT|E\-RECEIPT\sCONFIRMATION|ACCOUNT\sHOLDER|PAYMENT\sINFORMATION|ALIBABA\sINQUIRY\sNOTIFICATION|REPORT\sCONFIRMATION|ORDER\sRECEIPT\sREPORT|BILLING\sREPORT\sINFORMATION|URGENT\sREPLY)\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D)/gi;
	@count = grep defined, @count; 
	my $framed = scalar @count;
	my $set = 0;
	my $score = 0;
	my $rulename = "JR_FRAMED_WORDS";
	$framed = $framed / 3;

    if ( $framed >= 1 ) {
		if ( $framed == 1 ) {
			$score = $pms->{conf}->{chaos_tag} * 0.35;
		} else {
			$score = ($pms->{conf}->{chaos_tag} * 0.65 * $framed) - 0.1;
		}
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $framed";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	    if ( $framed >= 2 ) {
		$score = 0.1;
		my $rulename = "JR_M_FRAMED_WORDS";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm detection: Many Framed Words";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "HEADER: ", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
		}

    }

return 0;
}


=head2  useless_utf_check()

=over 5

=item  This is a Subject header test that looks for the presence of useless
Unicode filler characters: "CHAOS.pm dynamic score. Count: $totalcount"

=back

=over 5

=item  This score is variable, based upon the number of framed-digits detected.

=back

=cut

sub useless_utf_check {
	# https://www.utf8-chartable.de/unicode-utf8-table.pl
    my ( $self, $pms, $max ) = @_;
	my $subject1 = $pms->get('Subject');
    my $unicrap1 = () = $subject1 =~ /\xE2\x80\xAA|\xE2\x80\xAB|\xE2\x80\xAC|\xE2\x80\xAD|\xE2\x80\xAE|\xE2\x80\xAF|\xE2\x80\x8B|\xE2\x80\x8C|\xE2\x80\x8D|\xE2\x80\x8C|\xE2\x80\x90|\xE2\x80\x91|\xE2\x81\xA1|\xE2\x81\xA2|\xE2\x81\xA3|\xE2\x81\xA4|\xE2\x9D\xB6|\xE2\x9C\x89|\xEF\xBB\xBF|\xF0\x9F\x9A\x85/g;

    my $totalcount = $unicrap1;
    my $set = 0;
	my $score = 0;
	my $rulename = "JR_HDR_SUBJ_UTF8_CHARS";
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 3;
	}
    if ($totalcount > $max) {
		$score = $pms->{conf}->{chaos_tag} * 0.12 * $totalcount + $totalcount;
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $totalcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  check_for_sendgrid()

=over 5

=item  This tests all headers for the presence of Sendgrid. If found, the rule
JR_HAS_SENDGRID is scored appropriately, 0.35 * ${chaos_tag} and described:
"CHAOS.pm detection: Sendgrid in Headers"

=back

=over 5

=item  If Sendgrid headers are present, there is another test for their X-SG-EID 
header.  If not present, the score returned is: ${chaos_tag}.

=back

=cut

sub check_for_sendgrid {
    my ( $self, $pms ) = @_;
    my $subject = $pms->get('ALL');
	my $sgreference = $pms->get('References', undef);
	my $sg_eid = $pms->get("X-SG-EID", undef);
    my @count = $subject =~ /\bsendgrid\.net\b/g;
	@count = grep defined, @count; 
	my $sendgrid = scalar @count;
    my $set = 0;
	my $score = 0.3 * $pms->{conf}->{chaos_tag};
	my $rulename = "JR_HAS_SENDGRID";

    if ($sendgrid >= 1) {
			my $description = $pms->{conf}->{descriptions}->{"$rulename"};
			$description .= "CHAOS.pm detection: Sendgrid in Headers";
			$pms->{conf}->{descriptions}->{"$rulename"} = $description;
			$pms->got_hit("$rulename", "HEADER: ", score => $score);
			$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	
			# Check Sendgrid for their X-SG-EID header, otherwise invalid.
			# if( ! defined $sg_eid  && $sendgrid >= 1 ) {
			#	$rulename = "JR_BAD_SENDGRID";
			#	$score = $pms->{conf}->{chaos_high};
			#	my $description = $pms->{conf}->{descriptions}->{"$rulename"};
			#	$description .= "CHAOS.pm detection: Sendgrid Without X-SG-EID";
			#	$pms->{conf}->{descriptions}->{"$rulename"} = $description;
			#	$pms->got_hit("$rulename", "HEADER: ", score => $score);
			#	$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
			# }
	    }
	
return 0;
}


=head2  check_honorifics()

=over 5

=item  This tests the From Name field for honorifics; Mr./Mrs./Miss/Barrister/etc.
If found, rule JR_HONORIFICS is set and scored at: 0.33 * ${chaos_tag}.

=back

=cut

sub check_honorifics {
    my ( $self, $pms ) = @_;
	my $set = 0;
	my $count = 0;
	my $score = 0.33 * $pms->{conf}->{chaos_tag};
	my $rulename = "JR_HONORIFICS";
	my $firstword = "";
	my $restofname = "";
    my $from = $pms->get('From:name');
    if ( $from =~	 /^\"?(Mr|Mrs|Ms|Miss|Sir|Engineer|Engr|Lord|Advocate|Evangelist|Lawyer|Manager|Barrister|Solicitor|Esquire|Attorney|Prof|Professor|Sgt|Capt|Diplomat|Engr|Sr)(\.|\s|\,)/gi ) {
		$count = 1;
		($firstword,$restofname) = split(/[\s\.\,]/, $from);  
	# DE
	} elsif ( $from =~	 /^\"?(Herr|Frau?|Fraulein|Bruder|Schwester)(\.|\s|\,)/gi ) {
		$count = 1;
		($firstword,$restofname) = split(/[\s\.\,]/, $from);  
	# FR
	} elsif ( $from =~	 /^\"?(Monsieur|Mademoiselle|Madam|Mme\.|Avocat|Diplomate)(\.|\s|\,)/gi ) {
		$count = 1;
		($firstword,$restofname) = split(/[\s\.\,]/, $from);  
	# SE
	} elsif ( $from =~	 /^\"?(Fru|Fröken|Du|Herrn|Herre|Advokat|Statsman|Bror)(\.|\s|\,)/gi ) {
		$count = 1;
		($firstword,$restofname) = split(/[\s\.\,]/, $from);  
	# ES
	} elsif ( $from =~	 /^\"?(señor|caballero|señora|señorita|licenciado|doña|ud|tú|Hermano|Sor|Hermano|Abogado)/gi ) {
		$count = 1;
		($firstword,$restofname) = split(/[\s\.\,]/, $from);  
	}
	 
    if ($count >= 1) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Honorifics: $firstword";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  from_in_subject()

=over 5

=item  This tests looks for the presence of the From Name field in the Subject.
If so, rule JR_SUBJ_HAS_FROM_NAME is set, scored at: 0.6 * ${chaos_tag}.

=back

=cut

sub from_in_subject {
    my ( $self, $pms ) = @_;
	my $set = 0;
	my $count = 0;
	my $score = 0.6 * $pms->{conf}->{chaos_tag};
	my $rulename = "JR_SUBJ_HAS_FROM_NAME";
	my $subject = $pms->get('Subject');
    my $from = $pms->get('From:name');
	# Check for NO From Name, otherwise it will match.
	if (( $from ne "" ) &&  ( $subject =~ /^((My\sname\sis|From|Fra|Hello|It\'s\sme|Hola)?\s)?($from)$/gi )) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Subject has: $from";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  mailer_check()

=over 5

=item  Picks up the usual bad crappy mailers and services.  Rules returned
are JR_MAILER_BAT, JR_MAILER_PHP, JR_CHILKAT, JR_MAILKING, JR_SENDBLUE, 
JR_APPLE_XMAIL, JR_GEN_XMAILER, JR_CAMPAIGN_PRO, and JR_SWIFTMAILER.  Scores 
vary depending upon the mailer used.

=back

=cut

sub mailer_check {
    my ( $self, $pms ) = @_;
	my $swift = $pms->get('X-Gnkw-Mailer', undef);
	my $xmail = $pms->get('X-Mailer');
	my $allheaders = $pms->get('ALL');
	my $set = 0;
	my $score = 0;
	my $mailer = "";
	my $rulename = "JR_MAILER";
	if ( $xmail =~	/(The\sBat\!\s(\(v3\.71\.04\)\sHome|\(v3\.0\.1\.33\)\sProfessional|\(v2\.4.5\)\sPersonal|\(v3\.71\.14\)\sProfessional|\(v2\.4.5\)\sBusiness|\(v3\.71\.01\)\sHome|\(v3\.0\.1\sRC7\)\sUNREG\s\/\sE0XUKJWV2Y|\(v3\.60\.07\)\sProfessional|\(v3\.5\.25\)\sHome|\(v3\.62\.14\)\sEducational|\(v2\.04\.7\)\sBusiness\(v2\.00\.7\)\sPersonal|\(v2\.12\.00\)|\(v1\.51\)|\(v1\.60c\)|\(v3\.51\.4.5\)|\(v2\.00\.1\)|\(v1\.55\.3\)|\(v3\.62\.03\)|\(v2\.00\.8\)|\(v4\.54\.6\)|\(v2\.00\)\sEducational|\(v3\.65\.03\)\sHome|\(v2\.00\.7\)\sPersonal|\(v2\.12\.00\)\sBusiness|\(v2\.00\.6\)\sEducational|\(v2\.00\.6\)\sPersonal|\(v3\.5\.25\)\sHome|\(v3\.71\.01\)\sHome|\(3\.72\.01\)\sProfessional|\(v3\.80\.06\)\sEducational|\(v2\.4.5\.01\)\sEducational|\(v2\.00\.8\)\sBusiness|\(v2\.00\.5\)\sPersonal|\(v2\.12\.00\)\sPersonal|\(v3\.0\.1\.33\)\sProfessional|\(v2\.00\.1\)\sPersonal|\(v2\.00\.18\)\sEducational|\(v2\.00\.0\)\sPersonal|\(v2\.00\.9\)\sPersonal|\(v2\.00\.4\)\sPersonal|\(v2\.00\.2\)\sPersonal|\(v3\.80\.06\)\sProfessional|\(v3\.5\.30\)\sEducational|\(v3\.5\)\sHome|\(v3\.0\.1\.33\)|\(v3\.5\)\sProfessional|\(v3\.71\.14\)\sUNREG\s\/\sCD5BF9353B3B7091|\(v3\.0\)\sHome|\(v3\.81\.14\sBeta\)\sHome|\(v3\.62\.14\)\sEducational|\(v2\.00\.6\)\sPersonal|\(v2\.00\.6\)\sEducational|\(v3\.5\.25\)\sHome|\(v3\.80\.06\)\sEducational|\(v3\.71\.01\)\sHome|\(v3\.81\.14\sBeta\)\sHome))/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILER_BAT";
		$mailer = "Bad Bat Version";
	} elsif ( $xmail =~	/(The\sBat\!\s(\(v3\.81\.14\sBeta\)\sEducational|\(v2\.00\.6\)\sBusiness|\(v3\.80\.06\)\sHome|\(v2\.01\)\sPersonal|\(v2\.00\.3\)\sBusiness|\(v3\.81\.14\sBeta\)\sProfessional|\(v2\.4.5\.03\)\sEducational|\(v3\.51\)\sEducational|\(v3\.71\.01\)\sEducational|\(v3\.71\.14\)\sEducational|\(v2\.04\.7\)\sPersonal|\(v3\.0\.0\.15\)\sHome|\(v3\.5\.25\)\sHome|\(v4\.0\.24\)|\(v3\.65\.03\)\sHome|\(v3\.0\.0\.15\)\sProfessional|\(v2\.04\.7\)\sEducational|\(v2\.00\.9\)\sEducational|\(v3\.62\.14\)\sProfessional|\(v3\.81\.14\sBeta\)\sHome|\(v3\.62\.14\)\sUNREG\s\/\sCD5BF9353B3B7091|\(v2\.01\)\sBusiness|\(v3\.51\)\sHome|\(v2\.4.5\.03\)\sBusiness|\(v2\.00\.9\)\sPersonal|\(v2\.01\)|\(v3\.71\.01\)\sHome|\(v3\.71\.14\)\sProfessional|\(v3\.0\.1\.33\)\sEducational|\(v2\.00\.7\)\sEducational|\(v3\.5\)\sHome|\(v3\.0\.0\.15\)\sEducational|\(v2\.11\)\sPersonal|\(v3\.0\)\sProfessional|\(v2\.00\.18\)\sBusiness|\(v3\.80\.03\)\sHome|\(v2\.00\.0\)\sEducational|\(v2\.00\.7\)\sEducational|\(v2\.00\.3\)\sPersonal|\(v2\.00\.9\)\sBusiness|\(v2\.00\.0\)\sEducational\(v3\.71\.04\)\sEducational|\(v2\.00\.3\)\sEducational|\(v3\.0\.1\.33\)\sHome|\(v3\.0\.2\.2\sRush\)\sUNREG\s\/\sE0XUKJWV2Y|\(v3\.0\.1\.33\)|\(v2\.00\.4\)|\(v2\.00\.2\)|\(v2\.00\.7\)|\(v2\.00\.3\)|\(v2\.00\.6\)|\(v2\.00\.0\)|\(v3\.5\.30\)|\(v3\.6\.07\)|\(v2\.4.5\.03\)\sBusiness|\(v3\.80\.03\)\sProfessional|\(v3\.71\.01\)\sProfessional))/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILER_BAT";
		$mailer = "Bad Bat Version";
	} elsif	( $xmail =~	/PHPMailer\s5\.[0-1]\.[0-9]{1,2}/g ) {
		$score = 0.6 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILER_PHP";
		$mailer = "Obsolete PHP Mailer";
	} elsif	( $xmail =~	/PHPMailer\s5\.2\.[0-9]{1,2}/g ) {
		$score = 0.35 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILER_PHP";
		$mailer = "Old PHP Mailer";
	} elsif (( $xmail =~ /PHPMailer\s/g ) && ( $xmail !~ /\[version\s\d\.\d+\]/g )) {
		$score = 0.5 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILER_PHP";
		$mailer = "Forged PHP Mailer";
	} elsif	( $xmail =~	/Chilkat\sSoftware/g ) {
		$score = 0.21 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_CHILKAT";
		$mailer = "Chilkat";
	}  elsif	( $xmail =~	/MailKing/gi ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_MAILKING";
		$mailer = "Mail King";
	} elsif	( $xmail =~	/Sendinblue/g ) {
		$score = 0.35 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_SENDBLUE";
		$mailer = "Send In Blue";
	} elsif ( $xmail =~	/iPhone\sMail\s\([0-9A-Z]{5,6}\)|Apple\sMail\s\(2\.2104\)/g ) {
		$score = 0.15 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_APPLE_XMAIL";
		$mailer = "Bad iPhone-Apple";
	} elsif ( $xmail =~	/Ihffxjaaop\s\d/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Ihffxjaaop (JP)";
	} elsif	( $xmail =~	/xmail\sx3\ssupra/gi ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};	
		$rulename = "JR_GEN_XMAILER";		
		$mailer = "Supra Mailer";
	} elsif ( $xmail =~	/Avalanche/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Avalanche";
	} elsif ( $xmail =~	/Crescent\sInternet/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Crescent Tool";
	} elsif ( $xmail =~	/DiffondiCool/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "DiffondiCool";
	} elsif ( $xmail =~	/E\-Mail\sDelivery\sAgent/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Delivery Agent";
	} elsif ( $xmail =~	/Emailer\sPlatinum/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Platinum";
	} elsif ( $xmail =~	/Entity/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Entity";
	} elsif ( $xmail =~	/Extractor/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Extractor Pro";
	} elsif ( $xmail =~	/Floodgate/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Floodgate";
	} elsif ( $xmail =~	/GOTO\sSoftware/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "GOTO Software";
	} elsif ( $xmail =~	/MailWorkz/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "MailWorkz";
	} elsif ( $xmail =~	/MassE\-Mail/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Mass E-Mail";
	} elsif ( $xmail =~	/MaxBulk\.Mailer/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "MaxBulk";
	} elsif ( $xmail =~	/News\sBreaker/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "News Breaker Pro";
	} elsif ( $xmail =~	/SmartMailer/g ) {
		$score = 0.21 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "Smart Mailer";
	} elsif ( $xmail =~	/StormPort/g ) {
		$score = 0.21 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "StormPort";
	} elsif ( $xmail =~	/SuperMail\-2/g ) {
		$score = 0.21 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_GEN_XMAILER";
		$mailer = "SuperMail";
	}
	if ($score > 0) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm X-Mailer: $mailer";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
    }
	
	if ( $allheaders =~ /cp20\.com/g ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_CAMPAIGN_PRO";
		$mailer = "CampaignerPro";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Mailer: $mailer";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	}
	
	if ( defined $swift ) {
		$score = 0.57 * $pms->{conf}->{chaos_tag};
		$rulename = "JR_SWIFTMAILER";
		$mailer = "SwiftMailer";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm X-Mailer: $mailer";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
	}
		
return 0;
}

=head2  apple_detect()

=over 5

=item  Detects the Apple-Mail MIME boundary set by Apple in their e-mail applications.  This is a simple callout, and JR_APPLE_MIME merely scores at a value of 0.01.

=back

=cut

sub apple_detect {
    my ( $self, $pms ) = @_;
    my $mheader = $pms->get('Content-Type');
    my $apple = () = $mheader =~ /boundary\=.*Apple\-Mail\-.*/;
	my $set = 0;
	my $score = 0;
	my $rulename = "JR_APPLE_MIME";
	
    if ( $apple >= 1 ) {
		$score = 0.01;
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm detection: Apple MIME";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "BODY: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head2  check_utf_headers()

=over 5

=item  This tests for the presence of UTF-8 character codesets in the Subject, From, To and Reply-To fields.  The rules: JR_UTF8_SUBJ, JR_UTF8_FROM, R_UTF8_TO, and JR_UTF8_REPLYTO are callouts, set to a score of 0.01.

=back

=cut

sub check_utf_headers {
    my ( $self, $pms ) = @_;
    my $subject = $pms->get('Subject:raw');
    my $count = () = $subject =~ /(utf\-8)/gi;
    my $set = 0;
	my $score = 0.01;
	
    if ($count >= 1) {
		my $rulename = "JR_UTF8_SUBJ";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm UTF-8 in Subject";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	$count = 0;
	my $from = $pms->get('From:raw');
	$count = () = $from =~ /(utf\-8)/gi;
	
	if ($count >= 1) {
		my $rulename = "JR_UTF8_FROM";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm UTF-8 in From Name";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	$count = 0;
	my $uto = $pms->get('To:raw');
	$count = () = $uto =~ /(utf\-8)/gi;
	
	if ($count >= 1) {
		my $rulename = "JR_UTF8_TO";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm UTF-8 in To Name";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

	$count = 0;
	my $repto = $pms->get('Reply-To:raw');
	$count = () = $repto =~ /(utf\-8)/gi;
	
	if ($count >= 1) {
		my $rulename = "JR_UTF8_REPLYTO";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm UTF-8 in Reply-To Name";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }	
return 0;
}


=head2  check_replyto_length()

=over 5

=item  This checks the length of the Reply-To field.  When the length is excessive the rule, JR_LONG_REPLYTO, is set and scored at 0.37 * ${chaos_tag}.

=back

=cut

## From SpamAssassin Constants.pm:
## maximum byte length of lines in the body
#use constant MAX_BODY_LINE_LENGTH => 2048;
## maximum byte length of a header key
#use constant MAX_HEADER_KEY_LENGTH => 256;
## maximum byte length of a header value including continued lines
#use constant MAX_HEADER_VALUE_LENGTH => 8192;
## maximum byte length of entire header
#use constant MAX_HEADER_LENGTH => 65536;
## maximum byte length of any given URI
#use constant MAX_URI_LENGTH => 8192;

sub check_replyto_length {
    my ( $self, $pms, $max ) = @_;
    my $rto = $pms->get('Reply-To');
	my $size = length($rto);
    my $set = 0;
	my $score = 0.37 * $pms->{conf}->{chaos_tag};
	my $rulename = "JR_LONG_REPLYTO";
	if( ! defined $max || ( $max !~ /\d+/ ) ) {
		$max = 175;
	}
    
    if ($size > $max) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Reply-To is lengthy: $size";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  check_admin_fraud()

=over 5

=item  This is a Subject header test for Admin Fraud [Account Disabled] messages.  Also included are Subject header tests for the old SOBIG and SOBER worms.  JR_ADMIN_FRAUD is set to a value of ${chaos_high}.

=back

=cut

sub check_admin_fraud {
    my ( $self, $pms ) = @_;
    my $subject = $pms->get('Subject');
	my $set = 0;
	my $score = $pms->{conf}->{chaos_high};
	my $rulename = "JR_ADMIN_FRAUD";
	local $myadmin = "";
	local $mytob = "";
	local $mysober = "";
	local $sextortion = "";
	
	&admin_match();
	my @subcount = $subject =~ /($myadmin)/g;
	@subcount = grep defined, @subcount; 
	my $count = scalar @subcount;	
	# Include some of the old MYTOB worm subjects I've seen.
	&mytob_match();
	my @subcount1 = $subject =~ /($mytob)/g;
	@subcount1 = grep defined, @subcount1; 
	my $count1 = scalar @subcount1;	
	# Include some of the SOBER worm subjects I've observed.
	&sober_match();
	my @subcount2 = $subject =~ /($mysober)/g;
	@subcount2 = grep defined, @subcount2;
	my $count2 = scalar @subcount2;
	# Check some Aaron Smith Sextortion Subject headers
	&sextortion_subject();
	my @subcount3 = $subject =~ /($sextortion)/ig;
	@subcount3 = grep defined, @subcount3;
	my $count3 = scalar @subcount3;
	$count = $count + $count1 +$count2 + $count3;

    if ($count >= 1) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Admin Fraud/Worm/Extortion";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head2  check_admin_fraud_body()

=over 5

=item  This is a Body test that looks for Admin Fraud [Account Disabled, Quota Exceeded] messages.  This test is more expensive than standard Body rules which are pre-compiled with RE2C.  It's not bad, but still something to consider.  JR_ADMIN_BODY is set to a value of ${chaos_high} if a match is detected. 

=back

=cut

sub check_admin_fraud_body {
    my ( $self, $pms ) = @_;
	$count = 0;
	$JRbody = $pms->get_decoded_stripped_body_text_array();
	foreach my $line (@{$JRbody}) {
		my $i++;
		fraud_match1($count,$line);
		fraud_match2($count,$line);
		fraud_match3($count,$line);
		fraud_match4($count,$line);
		fraud_match5($count,$line);
		last if($count >= 1); #comment out for testing
		last if($i == 4000); #limit lines to look at
	} 

		
    my $set = 0;
	my $score = $pms->{conf}->{chaos_high};
	
	my $rulename = "JR_ADMIN_BODY";

    if ( $count != 0 ) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Admin Fraud in body: $count";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "BODY: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  from_lookalike_unicode()

=over 5

=item  This is a Header test of the From Name field.  This checks for Unicode "Look-Alike" characters used by Spammers to bypass standard eval tests. The scoring of the rule, JR_UNIBABBLE, is logarithmic and based upon the number of Unicode characters found. 

=back

=cut

# Look-alike characters in a name?  How many code sets does one need?
# I use a logarithmic function in scoring here.  No real reason, just 'cause.
sub from_lookalike_unicode {
    my ( $self, $pms ) = @_;
	my $code = 0;
	my $set = 0;
	my $rulename = "JR_UNIBABBLE";
    my $from = $pms->get('From:name');
	# ASCII
	if ( $from =~ /[a-zA-Z0-9]/g ) {
		$code++;
	}
	# GREEK1 https://www.utf8-chartable.de/unicode-utf8-table.pl?start=896&number=128&utf8=string-literal
	if ( $from =~ /\xCE\x86|\xCE\x87|\xCE\x88|\xCE\x89|\xCE\x8A|\xCE\x8B|\xCE\x8C|\xCE\x8D|\xCE\x8E|\xCE\x8F|\xCE\x90|\xCE\x91|\xCE\x92|\xCE\x93|\xCE\x94|\xCE\x95|\xCE\x96|\xCE\x97|\xCE\x98|\xCE\x99|\xCE\x9A|\xCE\x9B|\xCE\x9C|\xCE\x9D|\xCE\x9E|\xCE\x9F|\xCE\xA0|\xCE\xA1|\xCE\xA2|\xCE\xA3|\xCE\xA4|\xCE\xA5|\xCE\xA6|\xCE\xA7|\xCE\xA8|\xCE\xA9|\xCE\xAA|\xCE\xAB|\xCE\xAC|\xCE\xAD|\xCE\xAE|\xCE\xAF|\xCE\xB0|\xCE\xB1|\xCE\xB2|\xCE\xB3|\xCE\xB4|\xCE\xB5|\xCE\xB6|\xCE\xB7|\xCE\xB8|\xCE\xB9|\xCE\xBA|\xCE\xBB|\xCE\xBC|\xCE\xBD|\xCE\xBE|\xCE\xBF|\xCF\x80|\xCF\x81|\xCF\x82|\xCF\x83|\xCF\x84|\xCF\x85|\xCF\x86|\xCF\x87|\xCF\x88|\xCF\x89|\xCF\x8A|\xCF\x8B|\xCF\x8C|\xCF\x8D|\xCF\x8E|\xCF\x8F|\xCF\x90|\xCF\x91|\xCF\x92|\xCF\x93|\xCF\x94|\xCF\x95|\xCF\x96|\xCF\x97|\xCF\x98|\xCF\x99|\xCF\x9A|\xCF\x9B|\xCF\x9C|\xCF\x9D|\xCF\x9E|\xCF\x9F|\xCF\xA0|\xCF\xA1|\xCF\xA2|\xCF\xA3|\xCF\xA4|\xCF\xA5|\xCF\xA6|\xCF\xA7|\xCF\xA8|\xCF\xA9|\xCF\xAA|\xCF\xAB|\xCF\xAC|\xCF\xAD|\xCF\xAE|\xCF\xAF|\xCF\xB0|\xCF\xB1|\xCF\xB2|\xCF\xB3|\xCF\xB4|\xCF\xB5|\xCF\xB6|\xCF\xB7|\xCF\xB8|\xCF\xB9|\xCF\xBA|\xCF\xBB|\xCF\xBC|\xCF\xBD|\xCF\xBE|\xCF\xBF/g ) {
		$code++;
	}
	# CYRILIC/COPTIC/GREEK	https://utf8-chartable.de/unicode-utf8-table.pl?start=832&number=512&names=2&utf8=string-literal
	if ( $from =~ /\xCD\x80|\xCD\x81|\xCD\x82|\xCD\x83|\xCD\x84|\xCD\x85|\xCD\x86|\xCD\x87|\xCD\x88|\xCD\x89|\xCD\x8A|\xCD\x8B|\xCD\x8C|\xCD\x8D|\xCD\x8E|\xCD\x8F|\xCD\x90|\xCD\x91|\xCD\x92|\xCD\x93|\xCD\x94|\xCD\x95|\xCD\x96|\xCD\x97|\xCD\x98|\xCD\x99|\xCD\x9A|\xCD\x9B|\xCD\x9C|\xCD\x9D|\xCD\x9E|\xCD\x9F|\xCD\xA0|\xCD\xA1|\xCD\xA2|\xCD\xA3|\xCD\xA4|\xCD\xA5|\xCD\xA6|\xCD\xA7|\xCD\xA8|\xCD\xA9|\xCD\xAA|\xCD\xAB|\xCD\xAC|\xCD\xAD|\xCD\xAE|\xCD\xAF|\xCD\xB0|\xCD\xB1|\xCD\xB2|\xCD\xB3|\xCD\xB4|\xCD\xB5|\xCD\xB6|\xCD\xB7|\xCD\xB8|\xCD\xB9|\xCD\xBA|\xCD\xBB|\xCD\xBC|\xCD\xBD|\xCD\xBE|\xCD\xBF|\xCE\x80|\xCE\x81|\xCE\x82|\xCE\x83|\xCE\x84|\xCE\x85|\xCE\x86|\xCE\x87|\xCE\x88|\xCE\x89|\xCE\x8A|\xCE\x8B|\xCE\x8C|\xCE\x8D|\xCE\x8E|\xCE\x8F|\xCE\x90|\xCE\x91|\xCE\x92|\xCE\x93|\xCE\x94|\xCE\x95|\xCE\x96|\xCE\x97|\xCE\x98|\xCE\x99|\xCE\x9A|\xCE\x9B|\xCE\x9C|\xCE\x9D|\xCE\x9E|\xCE\x9F|\xCE\xA0|\xCE\xA1|\xCE\xA2|\xCE\xA3|\xCE\xA4|\xCE\xA5|\xCE\xA6|\xCE\xA7|\xCE\xA8|\xCE\xA9|\xCE\xAA|\xCE\xAB|\xCE\xAC|\xCE\xAD|\xCE\xAE|\xCE\xAF|\xCE\xB0|\xCE\xB1|\xCE\xB2|\xCE\xB3|\xCE\xB4|\xCE\xB5|\xCE\xB6|\xCE\xB7|\xCE\xB8|\xCE\xB9|\xCE\xBA|\xCE\xBB|\xCE\xBC|\xCE\xBD|\xCE\xBE|\xCE\xBF|\xCF\x80|\xCF\x81|\xCF\x82|\xCF\x83|\xCF\x84|\xCF\x85|\xCF\x86|\xCF\x87|\xCF\x88|\xCF\x89|\xCF\x8A|\xCF\x8B|\xCF\x8C|\xCF\x8D|\xCF\x8E|\xCF\x8F|\xCF\x90|\xCF\x91|\xCF\x92|\xCF\x93|\xCF\x94|\xCF\x95|\xCF\x96|\xCF\x97|\xCF\x98|\xCF\x99|\xCF\x9A|\xCF\x9B|\xCF\x9C|\xCF\x9D|\xCF\x9E|\xCF\x9F|\xCF\xA0|\xCF\xA1|\xCF\xA2|\xCF\xA3|\xCF\xA4|\xCF\xA5|\xCF\xA6|\xCF\xA7|\xCF\xA8|\xCF\xA9|\xCF\xAA|\xCF\xAB|\xCF\xAC|\xCF\xAD|\xCF\xAE|\xCF\xAF|\xCF\xB0|\xCF\xB1|\xCF\xB2|\xCF\xB3|\xCF\xB4|\xCF\xB5|\xCF\xB6|\xCF\xB7|\xCF\xB8|\xCF\xB9|\xCF\xBA|\xCF\xBB|\xCF\xBC|\xCF\xBD|\xCF\xBE|\xCF\xBF|\xD0\x80|\xD0\x81|\xD0\x82|\xD0\x83|\xD0\x84|\xD0\x85|\xD0\x86|\xD0\x87|\xD0\x88|\xD0\x89|\xD0\x8A|\xD0\x8B|\xD0\x8C|\xD0\x8D|\xD0\x8E|\xD0\x8F|\xD0\x90|\xD0\x91|\xD0\x92|\xD0\x93|\xD0\x94|\xD0\x95|\xD0\x96|\xD0\x97|\xD0\x98|\xD0\x99|\xD0\x9A|\xD0\x9B|\xD0\x9C|\xD0\x9D|\xD0\x9E|\xD0\x9F|\xD0\xA0|\xD0\xA1|\xD0\xA2|\xD0\xA3|\xD0\xA4|\xD0\xA5|\xD0\xA6|\xD0\xA7|\xD0\xA8|\xD0\xA9|\xD0\xAA|\xD0\xAB|\xD0\xAC|\xD0\xAD|\xD0\xAE|\xD0\xAF|\xD0\xB0|\xD0\xB1|\xD0\xB2|\xD0\xB3|\xD0\xB4|\xD0\xB5|\xD0\xB6|\xD0\xB7|\xD0\xB8|\xD0\xB9|\xD0\xBA|\xD0\xBB|\xD0\xBC|\xD0\xBD|\xD0\xBE|\xD0\xBF|\xD1\x80|\xD1\x81|\xD1\x82|\xD1\x83|\xD1\x84|\xD1\x85|\xD1\x86|\xD1\x87|\xD1\x88|\xD1\x89|\xD1\x8A|\xD1\x8B|\xD1\x8C|\xD1\x8D|\xD1\x8E|\xD1\x8F|\xD1\x90|\xD1\x91|\xD1\x92|\xD1\x93|\xD1\x94|\xD1\x95|\xD1\x96|\xD1\x97|\xD1\x98|\xD1\x99|\xD1\x9A|\xD1\x9B|\xD1\x9C|\xD1\x9D|\xD1\x9E|\xD1\x9F|\xD1\xA0|\xD1\xA1|\xD1\xA2|\xD1\xA3|\xD1\xA4|\xD1\xA5|\xD1\xA6|\xD1\xA7|\xD1\xA8|\xD1\xA9|\xD1\xAA|\xD1\xAB|\xD1\xAC|\xD1\xAD|\xD1\xAE|\xD1\xAF|\xD1\xB0|\xD1\xB1|\xD1\xB2|\xD1\xB3|\xD1\xB4|\xD1\xB5|\xD1\xB6|\xD1\xB7|\xD1\xB8|\xD1\xB9|\xD1\xBA|\xD1\xBB|\xD1\xBC|\xD1\xBD|\xD1\xBE|\xD1\xBF|\xD2\x80|\xD2\x81|\xD2\x82|\xD2\x83|\xD2\x84|\xD2\x85|\xD2\x86|\xD2\x87|\xD2\x88|\xD2\x89|\xD2\x8A|\xD2\x8B|\xD2\x8C|\xD2\x8D|\xD2\x8E|\xD2\x8F|\xD2\x90|\xD2\x91|\xD2\x92|\xD2\x93|\xD2\x94|\xD2\x95|\xD2\x96|\xD2\x97|\xD2\x98|\xD2\x99|\xD2\x9A|\xD2\x9B|\xD2\x9C|\xD2\x9D|\xD2\x9E|\xD2\x9F|\xD2\xA0|\xD2\xA1|\xD2\xA2|\xD2\xA3|\xD2\xA4|\xD2\xA5|\xD2\xA6|\xD2\xA7|\xD2\xA8|\xD2\xA9|\xD2\xAA|\xD2\xAB|\xD2\xAC|\xD2\xAD|\xD2\xAE|\xD2\xAF|\xD2\xB0|\xD2\xB1|\xD2\xB2|\xD2\xB3|\xD2\xB4|\xD2\xB5|\xD2\xB6|\xD2\xB7|\xD2\xB8|\xD2\xB9|\xD2\xBA|\xD2\xBB|\xD2\xBC|\xD2\xBD|\xD2\xBE|\xD2\xBF|\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF|\xD4\x80|\xD4\x81|\xD4\x82|\xD4\x83|\xD4\x84|\xD4\x85|\xD4\x86|\xD4\x87|\xD4\x88|\xD4\x89|\xD4\x8A|\xD4\x8B|\xD4\x8C|\xD4\x8D|\xD4\x8E|\xD4\x8F|\xD4\x90|\xD4\x91|\xD4\x92|\xD4\x93|\xD4\x94|\xD4\x95|\xD4\x96|\xD4\x97|\xD4\x98|\xD4\x99|\xD4\x9A|\xD4\x9B|\xD4\x9C|\xD4\x9D|\xD4\x9E|\xD4\x9F|\xD4\xA0|\xD4\xA1|\xD4\xA2|\xD4\xA3|\xD4\xA4|\xD4\xA5|\xD4\xA6|\xD4\xA7|\xD4\xA8|\xD4\xA9|\xD4\xAA|\xD4\xAB|\xD4\xAC|\xD4\xAD|\xD4\xAE|\xD4\xAF|\xD4\xB0|\xD4\xB1|\xD4\xB2|\xD4\xB3|\xD4\xB4|\xD4\xB5|\xD4\xB6|\xD4\xB7|\xD4\xB8|\xD4\xB9|\xD4\xBA|\xD4\xBB|\xD4\xBC|\xD4\xBD|\xD4\xBE|\xD4\xBF/g ) {
		$code++;
	}
	# LATIN EXT-B https://www.utf8-chartable.de/unicode-utf8-table.pl?start=512&utf8=string-literal
	if ( $from =~ /\xC8\x80|\xC8\x81|\xC8\x82|\xC8\x83|\xC8\x84|\xC8\x85|\xC8\x86|\xC8\x87|\xC8\x88|\xC8\x89|\xC8\x8A|\xC8\x8B|\xC8\x8C|\xC8\x8D|\xC8\x8E|\xC8\x8F|\xC8\x90|\xC8\x91|\xC8\x92|\xC8\x93|\xC8\x94|\xC8\x95|\xC8\x96|\xC8\x97|\xC8\x98|\xC8\x99|\xC8\x9A|\xC8\x9B|\xC8\x9C|\xC8\x9D|\xC8\x9E|\xC8\x9F|\xC8\xA0|\xC8\xA1|\xC8\xA2|\xC8\xA3|\xC8\xA4|\xC8\xA5|\xC8\xA6|\xC8\xA7|\xC8\xA8|\xC8\xA9|\xC8\xAA|\xC8\xAB|\xC8\xAC|\xC8\xAD|\xC8\xAE|\xC8\xAF|\xC8\xB0|\xC8\xB1|\xC8\xB2|\xC8\xB3|\xC8\xB4|\xC8\xB5|\xC8\xB6|\xC8\xB7|\xC8\xB8|\xC8\xB9|\xC8\xBA|\xC8\xBB|\xC8\xBC|\xC8\xBD|\xC8\xBE|\xC8\xBF|\xC9\x80|\xC9\x81|\xC9\x82|\xC9\x83|\xC9\x84|\xC9\x85|\xC9\x86|\xC9\x87|\xC9\x88|\xC9\x89|\xC9\x8A|\xC9\x8B|\xC9\x8C|\xC9\x8D|\xC9\x8E|\xC9\x8F|\xC9\x90|\xC9\x91|\xC9\x92|\xC9\x93|\xC9\x94|\xC9\x95|\xC9\x96|\xC9\x97|\xC9\x98|\xC9\x99|\xC9\x9A|\xC9\x9B|\xC9\x9C|\xC9\x9D|\xC9\x9E|\xC9\x9F|\xC9\xA0|\xC9\xA1|\xC9\xA2|\xC9\xA3|\xC9\xA4|\xC9\xA5|\xC9\xA6|\xC9\xA7|\xC9\xA8|\xC9\xA9|\xC9\xAA|\xC9\xAB|\xC9\xAC|\xC9\xAD|\xC9\xAE|\xC9\xAF|\xC9\xB0|\xC9\xB1|\xC9\xB2|\xC9\xB3|\xC9\xB4|\xC9\xB5|\xC9\xB6|\xC9\xB7|\xC9\xB8|\xC9\xB9|\xC9\xBA|\xC9\xBB|\xC9\xBC|\xC9\xBD|\xC9\xBE|\xC9\xBF|\xCA\x80|\xCA\x81|\xCA\x82|\xCA\x83|\xCA\x84|\xCA\x85|\xCA\x86|\xCA\x87|\xCA\x88|\xCA\x89|\xCA\x8A|\xCA\x8B|\xCA\x8C|\xCA\x8D|\xCA\x8E|\xCA\x8F|\xCA\x90|\xCA\x91|\xCA\x92|\xCA\x93|\xCA\x94|\xCA\x95|\xCA\x96|\xCA\x97|\xCA\x98|\xCA\x99|\xCA\x9A|\xCA\x9B|\xCA\x9C|\xCA\x9D|\xCA\x9E|\xCA\x9F|\xCA\xA0|\xCA\xA1|\xCA\xA2|\xCA\xA3|\xCA\xA4|\xCA\xA5|\xCA\xA6|\xCA\xA7|\xCA\xA8|\xCA\xA9|\xCA\xAA|\xCA\xAB|\xCA\xAC|\xCA\xAD|\xCA\xAE|\xCA\xAF|\xCA\xB0|\xCA\xB1|\xCA\xB2|\xCA\xB3|\xCA\xB4|\xCA\xB5|\xCA\xB6|\xCA\xB7|\xCA\xB8|\xCA\xB9|\xCA\xBA|\xCA\xBB|\xCA\xBC|\xCA\xBD|\xCA\xBE|\xCA\xBF|\xCB\x80|\xCB\x81|\xCB\x82|\xCB\x83|\xCB\x84|\xCB\x85|\xCB\x86|\xCB\x87|\xCB\x88|\xCB\x89|\xCB\x8A|\xCB\x8B|\xCB\x8C|\xCB\x8D|\xCB\x8E|\xCB\x8F|\xCB\x90|\xCB\x91|\xCB\x92|\xCB\x93|\xCB\x94|\xCB\x95|\xCB\x96|\xCB\x97|\xCB\x98|\xCB\x99|\xCB\x9A|\xCB\x9B|\xCB\x9C|\xCB\x9D|\xCB\x9E|\xCB\x9F|\xCB\xA0|\xCB\xA1|\xCB\xA2|\xCB\xA3|\xCB\xA4|\xCB\xA5|\xCB\xA6|\xCB\xA7|\xCB\xA8|\xCB\xA9|\xCB\xAA|\xCB\xAB|\xCB\xAC|\xCB\xAD|\xCB\xAE|\xCB\xAF|\xCB\xB0|\xCB\xB1|\xCB\xB2|\xCB\xB3|\xCB\xB4|\xCB\xB5|\xCB\xB6|\xCB\xB7|\xCB\xB8|\xCB\xB9|\xCB\xBA|\xCB\xBB|\xCB\xBC|\xCB\xBD|\xCB\xBE|\xCB\xBF/g ) {
		$code++;
	}
	# LETTER-LIKE SYMBOLS https://www.utf8-chartable.de/unicode-utf8-table.pl?start=8448&utf8=string-literal
	if ( $from =~ /\xE2\x84\x80|\xE2\x84\x81|\xE2\x84\x82|\xE2\x84\x83|\xE2\x84\x84|\xE2\x84\x85|\xE2\x84\x86|\xE2\x84\x87|\xE2\x84\x88|\xE2\x84\x89|\xE2\x84\x8A|\xE2\x84\x8B|\xE2\x84\x8C|\xE2\x84\x8D|\xE2\x84\x8E|\xE2\x84\x8F|\xE2\x84\x90|\xE2\x84\x91|\xE2\x84\x92|\xE2\x84\x93|\xE2\x84\x94|\xE2\x84\x95|\xE2\x84\x96|\xE2\x84\x97|\xE2\x84\x98|\xE2\x84\x99|\xE2\x84\x9A|\xE2\x84\x9B|\xE2\x84\x9C|\xE2\x84\x9D|\xE2\x84\x9E|\xE2\x84\x9F|\xE2\x84\xA0|\xE2\x84\xA1|\xE2\x84\xA2|\xE2\x84\xA3|\xE2\x84\xA4|\xE2\x84\xA5|\xE2\x84\xA6|\xE2\x84\xA7|\xE2\x84\xA8|\xE2\x84\xA9|\xE2\x84\xAA|\xE2\x84\xAB|\xE2\x84\xAC|\xE2\x84\xAD|\xE2\x84\xAE|\xE2\x84\xAF|\xE2\x84\xB0|\xE2\x84\xB1|\xE2\x84\xB2|\xE2\x84\xB3|\xE2\x84\xB4|\xE2\x84\xB5|\xE2\x84\xB6|\xE2\x84\xB7|\xE2\x84\xB8|\xE2\x84\xB9|\xE2\x84\xBA|\xE2\x84\xBB|\xE2\x84\xBC|\xE2\x84\xBD|\xE2\x84\xBE|\xE2\x84\xBF|\xE2\x85\x80|\xE2\x85\x81|\xE2\x85\x82|\xE2\x85\x83|\xE2\x85\x84|\xE2\x85\x85|\xE2\x85\x86|\xE2\x85\x87|\xE2\x85\x88|\xE2\x85\x89|\xE2\x85\x8A|\xE2\x85\x8B|\xE2\x85\x8C|\xE2\x85\x8D|\xE2\x85\x8E|\xE2\x85\x8F|\xE2\x85\x90|\xE2\x85\x91|\xE2\x85\x92|\xE2\x85\x93|\xE2\x85\x94|\xE2\x85\x95|\xE2\x85\x96|\xE2\x85\x97|\xE2\x85\x98|\xE2\x85\x99|\xE2\x85\x9A|\xE2\x85\x9B|\xE2\x85\x9C|\xE2\x85\x9D|\xE2\x85\x9E|\xE2\x85\x9F|\xE2\x85\xA0|\xE2\x85\xA1|\xE2\x85\xA2|\xE2\x85\xA3|\xE2\x85\xA4|\xE2\x85\xA5|\xE2\x85\xA6|\xE2\x85\xA7|\xE2\x85\xA8|\xE2\x85\xA9|\xE2\x85\xAA|\xE2\x85\xAB|\xE2\x85\xAC|\xE2\x85\xAD|\xE2\x85\xAE|\xE2\x85\xAF|\xE2\x85\xB0|\xE2\x85\xB1|\xE2\x85\xB2|\xE2\x85\xB3|\xE2\x85\xB4|\xE2\x85\xB5|\xE2\x85\xB6|\xE2\x85\xB7|\xE2\x85\xB8|\xE2\x85\xB9|\xE2\x85\xBA|\xE2\x85\xBB|\xE2\x85\xBC|\xE2\x85\xBD|\xE2\x85\xBE|\xE2\x85\xBF|\xE2\x86\x80|\xE2\x86\x81|\xE2\x86\x82|\xE2\x86\x83|\xE2\x86\x84|\xE2\x86\x85|\xE2\x86\x86|\xE2\x86\x87|\xE2\x86\x88|\xE2\x86\x89|\xE2\x86\x8A|\xE2\x86\x8B|\xE2\x86\x8C|\xE2\x86\x8D|\xE2\x86\x8E|\xE2\x86\x8F|\xE2\x86\x90|\xE2\x86\x91|\xE2\x86\x92|\xE2\x86\x93|\xE2\x86\x94|\xE2\x86\x95|\xE2\x86\x96|\xE2\x86\x97|\xE2\x86\x98|\xE2\x86\x99|\xE2\x86\x9A|\xE2\x86\x9B|\xE2\x86\x9C|\xE2\x86\x9D|\xE2\x86\x9E|\xE2\x86\x9F|\xE2\x86\xA0|\xE2\x86\xA1|\xE2\x86\xA2|\xE2\x86\xA3|\xE2\x86\xA4|\xE2\x86\xA5|\xE2\x86\xA6|\xE2\x86\xA7|\xE2\x86\xA8|\xE2\x86\xA9|\xE2\x86\xAA|\xE2\x86\xAB|\xE2\x86\xAC|\xE2\x86\xAD|\xE2\x86\xAE|\xE2\x86\xAF|\xE2\x86\xB0|\xE2\x86\xB1|\xE2\x86\xB2|\xE2\x86\xB3|\xE2\x86\xB4|\xE2\x86\xB5|\xE2\x86\xB6|\xE2\x86\xB7|\xE2\x86\xB8|\xE2\x86\xB9|\xE2\x86\xBA|\xE2\x86\xBB|\xE2\x86\xBC|\xE2\x86\xBD|\xE2\x86\xBE|\xE2\x86\xBF|\xE2\x87\x80|\xE2\x87\x81|\xE2\x87\x82|\xE2\x87\x83|\xE2\x87\x84|\xE2\x87\x85|\xE2\x87\x86|\xE2\x87\x87|\xE2\x87\x88|\xE2\x87\x89|\xE2\x87\x8A|\xE2\x87\x8B|\xE2\x87\x8C|\xE2\x87\x8D|\xE2\x87\x8E|\xE2\x87\x8F|\xE2\x87\x90|\xE2\x87\x91|\xE2\x87\x92|\xE2\x87\x93|\xE2\x87\x94|\xE2\x87\x95|\xE2\x87\x96|\xE2\x87\x97|\xE2\x87\x98|\xE2\x87\x99|\xE2\x87\x9A|\xE2\x87\x9B|\xE2\x87\x9C|\xE2\x87\x9D|\xE2\x87\x9E|\xE2\x87\x9F|\xE2\x87\xA0|\xE2\x87\xA1|\xE2\x87\xA2|\xE2\x87\xA3|\xE2\x87\xA4|\xE2\x87\xA5|\xE2\x87\xA6|\xE2\x87\xA7|\xE2\x87\xA8|\xE2\x87\xA9|\xE2\x87\xAA|\xE2\x87\xAB|\xE2\x87\xAC|\xE2\x87\xAD|\xE2\x87\xAE|\xE2\x87\xAF|\xE2\x87\xB0|\xE2\x87\xB1|\xE2\x87\xB2|\xE2\x87\xB3|\xE2\x87\xB4|\xE2\x87\xB5|\xE2\x87\xB6|\xE2\x87\xB7|\xE2\x87\xB8|\xE2\x87\xB9|\xE2\x87\xBA|\xE2\x87\xBB|\xE2\x87\xBC|\xE2\x87\xBD|\xE2\x87\xBE|\xE2\x87\xBF/g ) {
		$code++;
	}
	# LATIN SUPPLEMENT https://www.utf8-chartable.de/unicode-utf8-table.pl?start=128&number=128&utf8=string-literal
	if ( $from =~ /\xC2\xA0|\xC2\xA1|\xC2\xA2|\xC2\xA3|\xC2\xA4|\xC2\xA5|\xC2\xA6|\xC2\xA7|\xC2\xA8|\xC2\xA9|\xC2\xAA|\xC2\xAB|\xC2\xAC|\xC2\xAD|\xC2\xAE|\xC2\xAF|\xC2\xB0|\xC2\xB1|\xC2\xB2|\xC2\xB3|\xC2\xB4|\xC2\xB5|\xC2\xB6|\xC2\xB7|\xC2\xB8|\xC2\xB9|\xC2\xBA|\xC2\xBB|\xC2\xBC|\xC2\xBD|\xC2\xBE|\xC2\xBF|\xC3\x80|\xC3\x81|\xC3\x82|\xC3\x83|\xC3\x84|\xC3\x85|\xC3\x86|\xC3\x87|\xC3\x88|\xC3\x89|\xC3\x8A|\xC3\x8B|\xC3\x8C|\xC3\x8D|\xC3\x8E|\xC3\x8F|\xC3\x90|\xC3\x91|\xC3\x92|\xC3\x93|\xC3\x94|\xC3\x95|\xC3\x96|\xC3\x97|\xC3\x98|\xC3\x99|\xC3\x9A|\xC3\x9B|\xC3\x9C|\xC3\x9D|\xC3\x9E|\xC3\x9F|\xC3\xA0|\xC3\xA1|\xC3\xA2|\xC3\xA3|\xC3\xA4|\xC3\xA5|\xC3\xA6|\xC3\xA7|\xC3\xA8|\xC3\xA9|\xC3\xAA|\xC3\xAB|\xC3\xAC|\xC3\xAD|\xC3\xAE|\xC3\xAF|\xC3\xB0|\xC3\xB1|\xC3\xB2|\xC3\xB3|\xC3\xB4|\xC3\xB5|\xC3\xB6|\xC3\xB7|\xC3\xB8|\xC3\xB9|\xC3\xBA|\xC3\xBB|\xC3\xBC|\xC3\xBD|\xC3\xBE|\xC3\xBF/g ) {
		$code++;
	}
	# LATIN EXT-A https://www.utf8-chartable.de/unicode-utf8-table.pl?start=256&utf8=string-literal
	if ( $from =~ /\xC4\x80|\xC4\x81|\xC4\x82|\xC4\x83|\xC4\x84|\xC4\x85|\xC4\x86|\xC4\x87|\xC4\x88|\xC4\x89|\xC4\x8A|\xC4\x8B|\xC4\x8C|\xC4\x8D|\xC4\x8E|\xC4\x8F|\xC4\x90|\xC4\x91|\xC4\x92|\xC4\x93|\xC4\x94|\xC4\x95|\xC4\x96|\xC4\x97|\xC4\x98|\xC4\x99|\xC4\x9A|\xC4\x9B|\xC4\x9C|\xC4\x9D|\xC4\x9E|\xC4\x9F|\xC4\xA0|\xC4\xA1|\xC4\xA2|\xC4\xA3|\xC4\xA4|\xC4\xA5|\xC4\xA6|\xC4\xA7|\xC4\xA8|\xC4\xA9|\xC4\xAA|\xC4\xAB|\xC4\xAC|\xC4\xAD|\xC4\xAE|\xC4\xAF|\xC4\xB0|\xC4\xB1|\xC4\xB2|\xC4\xB3|\xC4\xB4|\xC4\xB5|\xC4\xB6|\xC4\xB7|\xC4\xB8|\xC4\xB9|\xC4\xBA|\xC4\xBB|\xC4\xBC|\xC4\xBD|\xC4\xBE|\xC4\xBF|\xC5\x80|\xC5\x81|\xC5\x82|\xC5\x83|\xC5\x84|\xC5\x85|\xC5\x86|\xC5\x87|\xC5\x88|\xC5\x89|\xC5\x8A|\xC5\x8B|\xC5\x8C|\xC5\x8D|\xC5\x8E|\xC5\x8F|\xC5\x90|\xC5\x91|\xC5\x92|\xC5\x93|\xC5\x94|\xC5\x95|\xC5\x96|\xC5\x97|\xC5\x98|\xC5\x99|\xC5\x9A|\xC5\x9B|\xC5\x9C|\xC5\x9D|\xC5\x9E|\xC5\x9F|\xC5\xA0|\xC5\xA1|\xC5\xA2|\xC5\xA3|\xC5\xA4|\xC5\xA5|\xC5\xA6|\xC5\xA7|\xC5\xA8|\xC5\xA9|\xC5\xAA|\xC5\xAB|\xC5\xAC|\xC5\xAD|\xC5\xAE|\xC5\xAF|\xC5\xB0|\xC5\xB1|\xC5\xB2|\xC5\xB3|\xC5\xB4|\xC5\xB5|\xC5\xB6|\xC5\xB7|\xC5\xB8|\xC5\xB9|\xC5\xBA|\xC5\xBB|\xC5\xBC|\xC5\xBD|\xC5\xBE|\xC5\xBF|\xC6\x80|\xC6\x81|\xC6\x82|\xC6\x83|\xC6\x84|\xC6\x85|\xC6\x86|\xC6\x87|\xC6\x88|\xC6\x89|\xC6\x8A|\xC6\x8B|\xC6\x8C|\xC6\x8D|\xC6\x8E|\xC6\x8F|\xC6\x90|\xC6\x91|\xC6\x92|\xC6\x93|\xC6\x94|\xC6\x95|\xC6\x96|\xC6\x97|\xC6\x98|\xC6\x99|\xC6\x9A|\xC6\x9B|\xC6\x9C|\xC6\x9D|\xC6\x9E|\xC6\x9F|\xC6\xA0|\xC6\xA1|\xC6\xA2|\xC6\xA3|\xC6\xA4|\xC6\xA5|\xC6\xA6|\xC6\xA7|\xC6\xA8|\xC6\xA9|\xC6\xAA|\xC6\xAB|\xC6\xAC|\xC6\xAD|\xC6\xAE|\xC6\xAF|\xC6\xB0|\xC6\xB1|\xC6\xB2|\xC6\xB3|\xC6\xB4|\xC6\xB5|\xC6\xB6|\xC6\xB7|\xC6\xB8|\xC6\xB9|\xC6\xBA|\xC6\xBB|\xC6\xBC|\xC6\xBD|\xC6\xBE|\xC6\xBF|\xC7\x80|\xC7\x81|\xC7\x82|\xC7\x83|\xC7\x84|\xC7\x85|\xC7\x86|\xC7\x87|\xC7\x88|\xC7\x89|\xC7\x8A|\xC7\x8B|\xC7\x8C|\xC7\x8D|\xC7\x8E|\xC7\x8F|\xC7\x90|\xC7\x91|\xC7\x92|\xC7\x93|\xC7\x94|\xC7\x95|\xC7\x96|\xC7\x97|\xC7\x98|\xC7\x99|\xC7\x9A|\xC7\x9B|\xC7\x9C|\xC7\x9D|\xC7\x9E|\xC7\x9F|\xC7\xA0|\xC7\xA1|\xC7\xA2|\xC7\xA3|\xC7\xA4|\xC7\xA5|\xC7\xA6|\xC7\xA7|\xC7\xA8|\xC7\xA9|\xC7\xAA|\xC7\xAB|\xC7\xAC|\xC7\xAD|\xC7\xAE|\xC7\xAF|\xC7\xB0|\xC7\xB1|\xC7\xB2|\xC7\xB3|\xC7\xB4|\xC7\xB5|\xC7\xB6|\xC7\xB7|\xC7\xB8|\xC7\xB9|\xC7\xBA|\xC7\xBB|\xC7\xBC|\xC7\xBD|\xC7\xBE|\xC7\xBF/g ) {
		$code++;
	}
	# LATIN 1-SUP https://www.utf8-chartable.de/unicode-utf8-table.pl?start=128&number=128&names=-&utf8=string-literal
    if ( $from =~ /\xC2\x80|\xC2\x81|\xC2\x82|\xC2\x83|\xC2\x84|\xC2\x85|\xC2\x86|\xC2\x87|\xC2\x88|\xC2\x89|\xC2\x8A|\xC2\x8B|\xC2\x8C|\xC2\x8D|\xC2\x8E|\xC2\x8F|\xC2\x90|\xC2\x91|\xC2\x92|\xC2\x93|\xC2\x94|\xC2\x95|\xC2\x96|\xC2\x97|\xC2\x98|\xC2\x99|\xC2\x9A|\xC2\x9B|\xC2\x9C|\xC2\x9D|\xC2\x9E|\xC2\x9F|\xC2\xA0|\xC2\xA1|\xC2\xA2|\xC2\xA3|\xC2\xA4|\xC2\xA5|\xC2\xA6|\xC2\xA7|\xC2\xA8|\xC2\xA9|\xC2\xAA|\xC2\xAB|\xC2\xAC|\xC2\xAD|\xC2\xAE|\xC2\xAF|\xC2\xB0|\xC2\xB1|\xC2\xB2|\xC2\xB3|\xC2\xB4|\xC2\xB5|\xC2\xB6|\xC2\xB7|\xC2\xB8|\xC2\xB9|\xC2\xBA|\xC2\xBB|\xC2\xBC|\xC2\xBD|\xC2\xBE|\xC2\xBF|\xC3\x80|\xC3\x81|\xC3\x82|\xC3\x83|\xC3\x84|\xC3\x85|\xC3\x86|\xC3\x87|\xC3\x88|\xC3\x89|\xC3\x8A|\xC3\x8B|\xC3\x8C|\xC3\x8D|\xC3\x8E|\xC3\x8F|\xC3\x90|\xC3\x91|\xC3\x92|\xC3\x93|\xC3\x94|\xC3\x95|\xC3\x96|\xC3\x97|\xC3\x98|\xC3\x99|\xC3\x9A|\xC3\x9B|\xC3\x9C|\xC3\x9D|\xC3\x9E|\xC3\x9F|\xC3\xA0|\xC3\xA1|\xC3\xA2|\xC3\xA3|\xC3\xA4|\xC3\xA5|\xC3\xA6|\xC3\xA7|\xC3\xA8|\xC3\xA9|\xC3\xAA|\xC3\xAB|\xC3\xAC|\xC3\xAD|\xC3\xAE|\xC3\xAF|\xC3\xB0|\xC3\xB1|\xC3\xB2|\xC3\xB3|\xC3\xB4|\xC3\xB5|\xC3\xB6|\xC3\xB7|\xC3\xB8|\xC3\xB9|\xC3\xBA|\xC3\xBB|\xC3\xBC|\xC3\xBD|\xC3\xBE|\xC3\xBF/g ) {
		$code++;
	}
	# CYRILLIC https://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024&number=128&names=-&utf8=string-literal
	#          https://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024&names=-&utf8=string-literal
	if ( $from =~ /\xD0\x80|\xD0\x81|\xD0\x82|\xD0\x83|\xD0\x84|\xD0\x85|\xD0\x86|\xD0\x87|\xD0\x88|\xD0\x89|\xD0\x8A|\xD0\x8B|\xD0\x8C|\xD0\x8D|\xD0\x8E|\xD0\x8F|\xD0\x90|\xD0\x91|\xD0\x92|\xD0\x93|\xD0\x94|\xD0\x95|\xD0\x96|\xD0\x97|\xD0\x98|\xD0\x99|\xD0\x9A|\xD0\x9B|\xD0\x9C|\xD0\x9D|\xD0\x9E|\xD0\x9F|\xD0\xA0|\xD0\xA1|\xD0\xA2|\xD0\xA3|\xD0\xA4|\xD0\xA5|\xD0\xA6|\xD0\xA7|\xD0\xA8|\xD0\xA9|\xD0\xAA|\xD0\xAB|\xD0\xAC|\xD0\xAD|\xD0\xAE|\xD0\xAF|\xD0\xB0|\xD0\xB1|\xD0\xB2|\xD0\xB3|\xD0\xB4|\xD0\xB5|\xD0\xB6|\xD0\xB7|\xD0\xB8|\xD0\xB9|\xD0\xBA|\xD0\xBB|\xD0\xBC|\xD0\xBD|\xD0\xBE|\xD0\xBF|\xD1\x80|\xD1\x81|\xD1\x82|\xD1\x83|\xD1\x84|\xD1\x85|\xD1\x86|\xD1\x87|\xD1\x88|\xD1\x89|\xD1\x8A|\xD1\x8B|\xD1\x8C|\xD1\x8D|\xD1\x8E|\xD1\x8F|\xD1\x90|\xD1\x91|\xD1\x92|\xD1\x93|\xD1\x94|\xD1\x95|\xD1\x96|\xD1\x97|\xD1\x98|\xD1\x99|\xD1\x9A|\xD1\x9B|\xD1\x9C|\xD1\x9D|\xD1\x9E|\xD1\x9F|\xD1\xA0|\xD1\xA1|\xD1\xA2|\xD1\xA3|\xD1\xA4|\xD1\xA5|\xD1\xA6|\xD1\xA7|\xD1\xA8|\xD1\xA9|\xD1\xAA|\xD1\xAB|\xD1\xAC|\xD1\xAD|\xD1\xAE|\xD1\xAF|\xD1\xB0|\xD1\xB1|\xD1\xB2|\xD1\xB3|\xD1\xB4|\xD1\xB5|\xD1\xB6|\xD1\xB7|\xD1\xB8|\xD1\xB9|\xD1\xBA|\xD1\xBB|\xD1\xBC|\xD1\xBD|\xD1\xBE|\xD1\xBF|\xD2\x80|\xD2\x81|\xD2\x82|\xD2\x83|\xD2\x84|\xD2\x85|\xD2\x86|\xD2\x87|\xD2\x88|\xD2\x89|\xD2\x8A|\xD2\x8B|\xD2\x8C|\xD2\x8D|\xD2\x8E|\xD2\x8F|\xD2\x90|\xD2\x91|\xD2\x92|\xD2\x93|\xD2\x94|\xD2\x95|\xD2\x96|\xD2\x97|\xD2\x98|\xD2\x99|\xD2\x9A|\xD2\x9B|\xD2\x9C|\xD2\x9D|\xD2\x9E|\xD2\x9F|\xD2\xA0|\xD2\xA1|\xD2\xA2|\xD2\xA3|\xD2\xA4|\xD2\xA5|\xD2\xA6|\xD2\xA7|\xD2\xA8|\xD2\xA9|\xD2\xAA|\xD2\xAB|\xD2\xAC|\xD2\xAD|\xD2\xAE|\xD2\xAF|\xD2\xB0|\xD2\xB1|\xD2\xB2|\xD2\xB3|\xD2\xB4|\xD2\xB5|\xD2\xB6|\xD2\xB7|\xD2\xB8|\xD2\xB9|\xD2\xBA|\xD2\xBB|\xD2\xBC|\xD2\xBD|\xD2\xBE|\xD2\xBF|\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF/g ) {
		$code++;
	}
	# CYRILLIC https://utf8-chartable.de/unicode-utf8-table.pl?start=1216&number=512&names=-&utf8=string-literal
	if ( $from =~ /\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF|\xD4\x80|\xD4\x81|\xD4\x82|\xD4\x83|\xD4\x84|\xD4\x85|\xD4\x86|\xD4\x87|\xD4\x88|\xD4\x89|\xD4\x8A|\xD4\x8B|\xD4\x8C|\xD4\x8D|\xD4\x8E|\xD4\x8F|\xD4\x90|\xD4\x91|\xD4\x92|\xD4\x93|\xD4\x94|\xD4\x95|\xD4\x96|\xD4\x97|\xD4\x98|\xD4\x99|\xD4\x9A|\xD4\x9B|\xD4\x9C|\xD4\x9D|\xD4\x9E|\xD4\x9F|\xD4\xA0|\xD4\xA1|\xD4\xA2|\xD4\xA3|\xD4\xA4|\xD4\xA5|\xD4\xA6|\xD4\xA7|\xD4\xA8|\xD4\xA9|\xD4\xAA|\xD4\xAB|\xD4\xAC|\xD4\xAD|\xD4\xAE|\xD4\xAF|\xD4\xB0|\xD4\xB1|\xD4\xB2|\xD4\xB3|\xD4\xB4|\xD4\xB5|\xD4\xB6|\xD4\xB7|\xD4\xB8|\xD4\xB9|\xD4\xBA|\xD4\xBB|\xD4\xBC|\xD4\xBD|\xD4\xBE|\xD4\xBF|\xD5\x80|\xD5\x81|\xD5\x82|\xD5\x83|\xD5\x84|\xD5\x85|\xD5\x86|\xD5\x87|\xD5\x88|\xD5\x89|\xD5\x8A|\xD5\x8B|\xD5\x8C|\xD5\x8D|\xD5\x8E|\xD5\x8F|\xD5\x90|\xD5\x91|\xD5\x92|\xD5\x93|\xD5\x94|\xD5\x95|\xD5\x96|\xD5\x97|\xD5\x98|\xD5\x99|\xD5\x9A|\xD5\x9B|\xD5\x9C|\xD5\x9D|\xD5\x9E|\xD5\x9F|\xD5\xA0|\xD5\xA1|\xD5\xA2|\xD5\xA3|\xD5\xA4|\xD5\xA5|\xD5\xA6|\xD5\xA7|\xD5\xA8|\xD5\xA9|\xD5\xAA|\xD5\xAB|\xD5\xAC|\xD5\xAD|\xD5\xAE|\xD5\xAF|\xD5\xB0|\xD5\xB1|\xD5\xB2|\xD5\xB3|\xD5\xB4|\xD5\xB5|\xD5\xB6|\xD5\xB7|\xD5\xB8|\xD5\xB9|\xD5\xBA|\xD5\xBB|\xD5\xBC|\xD5\xBD|\xD5\xBE|\xD5\xBF|\xD6\x80|\xD6\x81|\xD6\x82|\xD6\x83|\xD6\x84|\xD6\x85|\xD6\x86|\xD6\x87|\xD6\x88|\xD6\x89|\xD6\x8A|\xD6\x8B|\xD6\x8C|\xD6\x8D|\xD6\x8E|\xD6\x8F|\xD6\x90|\xD6\x91|\xD6\x92|\xD6\x93|\xD6\x94|\xD6\x95|\xD6\x96|\xD6\x97|\xD6\x98|\xD6\x99|\xD6\x9A|\xD6\x9B|\xD6\x9C|\xD6\x9D|\xD6\x9E|\xD6\x9F|\xD6\xA0|\xD6\xA1|\xD6\xA2|\xD6\xA3|\xD6\xA4|\xD6\xA5|\xD6\xA6|\xD6\xA7|\xD6\xA8|\xD6\xA9|\xD6\xAA|\xD6\xAB|\xD6\xAC|\xD6\xAD|\xD6\xAE|\xD6\xAF|\xD6\xB0|\xD6\xB1|\xD6\xB2|\xD6\xB3|\xD6\xB4|\xD6\xB5|\xD6\xB6|\xD6\xB7|\xD6\xB8|\xD6\xB9|\xD6\xBA|\xD6\xBB|\xD6\xBC|\xD6\xBD|\xD6\xBE|\xD6\xBF|\xD7\x80|\xD7\x81|\xD7\x82|\xD7\x83|\xD7\x84|\xD7\x85|\xD7\x86|\xD7\x87|\xD7\x88|\xD7\x89|\xD7\x8A|\xD7\x8B|\xD7\x8C|\xD7\x8D|\xD7\x8E|\xD7\x8F|\xD7\x90|\xD7\x91|\xD7\x92|\xD7\x93|\xD7\x94|\xD7\x95|\xD7\x96|\xD7\x97|\xD7\x98|\xD7\x99|\xD7\x9A|\xD7\x9B|\xD7\x9C|\xD7\x9D|\xD7\x9E|\xD7\x9F|\xD7\xA0|\xD7\xA1|\xD7\xA2|\xD7\xA3|\xD7\xA4|\xD7\xA5|\xD7\xA6|\xD7\xA7|\xD7\xA8|\xD7\xA9|\xD7\xAA|\xD7\xAB|\xD7\xAC|\xD7\xAD|\xD7\xAE|\xD7\xAF|\xD7\xB0|\xD7\xB1|\xD7\xB2|\xD7\xB3|\xD7\xB4|\xD7\xB5|\xD7\xB6|\xD7\xB7|\xD7\xB8|\xD7\xB9|\xD7\xBA|\xD7\xBB|\xD7\xBC|\xD7\xBD|\xD7\xBE|\xD7\xBF|\xD8\x80|\xD8\x81|\xD8\x82|\xD8\x83|\xD8\x84|\xD8\x85|\xD8\x86|\xD8\x87|\xD8\x88|\xD8\x89|\xD8\x8A|\xD8\x8B|\xD8\x8C|\xD8\x8D|\xD8\x8E|\xD8\x8F|\xD8\x90|\xD8\x91|\xD8\x92|\xD8\x93|\xD8\x94|\xD8\x95|\xD8\x96|\xD8\x97|\xD8\x98|\xD8\x99|\xD8\x9A|\xD8\x9B|\xD8\x9C|\xD8\x9D|\xD8\x9E|\xD8\x9F|\xD8\xA0|\xD8\xA1|\xD8\xA2|\xD8\xA3|\xD8\xA4|\xD8\xA5|\xD8\xA6|\xD8\xA7|\xD8\xA8|\xD8\xA9|\xD8\xAA|\xD8\xAB|\xD8\xAC|\xD8\xAD|\xD8\xAE|\xD8\xAF|\xD8\xB0|\xD8\xB1|\xD8\xB2|\xD8\xB3|\xD8\xB4|\xD8\xB5|\xD8\xB6|\xD8\xB7|\xD8\xB8|\xD8\xB9|\xD8\xBA|\xD8\xBB|\xD8\xBC|\xD8\xBD|\xD8\xBE|\xD8\xBF|\xD9\x80|\xD9\x81|\xD9\x82|\xD9\x83|\xD9\x84|\xD9\x85|\xD9\x86|\xD9\x87|\xD9\x88|\xD9\x89|\xD9\x8A|\xD9\x8B|\xD9\x8C|\xD9\x8D|\xD9\x8E|\xD9\x8F|\xD9\x90|\xD9\x91|\xD9\x92|\xD9\x93|\xD9\x94|\xD9\x95|\xD9\x96|\xD9\x97|\xD9\x98|\xD9\x99|\xD9\x9A|\xD9\x9B|\xD9\x9C|\xD9\x9D|\xD9\x9E|\xD9\x9F|\xD9\xA0|\xD9\xA1|\xD9\xA2|\xD9\xA3|\xD9\xA4|\xD9\xA5|\xD9\xA6|\xD9\xA7|\xD9\xA8|\xD9\xA9|\xD9\xAA|\xD9\xAB|\xD9\xAC|\xD9\xAD|\xD9\xAE|\xD9\xAF|\xD9\xB0|\xD9\xB1|\xD9\xB2|\xD9\xB3|\xD9\xB4|\xD9\xB5|\xD9\xB6|\xD9\xB7|\xD9\xB8|\xD9\xB9|\xD9\xBA|\xD9\xBB|\xD9\xBC|\xD9\xBD|\xD9\xBE|\xD9\xBF|\xDA\x80|\xDA\x81|\xDA\x82|\xDA\x83|\xDA\x84|\xDA\x85|\xDA\x86|\xDA\x87|\xDA\x88|\xDA\x89|\xDA\x8A|\xDA\x8B|\xDA\x8C|\xDA\x8D|\xDA\x8E|\xDA\x8F|\xDA\x90|\xDA\x91|\xDA\x92|\xDA\x93|\xDA\x94|\xDA\x95|\xDA\x96|\xDA\x97|\xDA\x98|\xDA\x99|\xDA\x9A|\xDA\x9B|\xDA\x9C|\xDA\x9D|\xDA\x9E|\xDA\x9F|\xDA\xA0|\xDA\xA1|\xDA\xA2|\xDA\xA3|\xDA\xA4|\xDA\xA5|\xDA\xA6|\xDA\xA7|\xDA\xA8|\xDA\xA9|\xDA\xAA|\xDA\xAB|\xDA\xAC|\xDA\xAD|\xDA\xAE|\xDA\xAF|\xDA\xB0|\xDA\xB1|\xDA\xB2|\xDA\xB3|\xDA\xB4|\xDA\xB5|\xDA\xB6|\xDA\xB7|\xDA\xB8|\xDA\xB9|\xDA\xBA|\xDA\xBB|\xDA\xBC|\xDA\xBD|\xDA\xBE|\xDA\xBF/g ) {
		$code++;
	}
	my @utfcount = $from =~ /\xF0\x9F\x84\x80|\xF0\x9F\x84\x81|\xF0\x9F\x84\x82|\xF0\x9F\x84\x83|\xF0\x9F\x84\x84|\xF0\x9F\x84\x85|\xF0\x9F\x84\x86|\xF0\x9F\x84\x87|\xF0\x9F\x84\x88|\xF0\x9F\x84\x89|\xF0\x9F\x84\x8A|\xF0\x9F\x84\x8B|\xF0\x9F\x84\x8C|\xF0\x9F\x84\x8D|\xF0\x9F\x84\x8E|\xF0\x9F\x84\x8F|\xF0\x9F\x84\x90|\xF0\x9F\x84\x91|\xF0\x9F\x84\x92|\xF0\x9F\x84\x93|\xF0\x9F\x84\x94|\xF0\x9F\x84\x95|\xF0\x9F\x84\x96|\xF0\x9F\x84\x97|\xF0\x9F\x84\x98|\xF0\x9F\x84\x99|\xF0\x9F\x84\x9A|\xF0\x9F\x84\x9B|\xF0\x9F\x84\x9C|\xF0\x9F\x84\x9D|\xF0\x9F\x84\x9E|\xF0\x9F\x84\x9F|\xF0\x9F\x84\xA0|\xF0\x9F\x84\xA1|\xF0\x9F\x84\xA2|\xF0\x9F\x84\xA3|\xF0\x9F\x84\xA4|\xF0\x9F\x84\xA5|\xF0\x9F\x84\xA6|\xF0\x9F\x84\xA7|\xF0\x9F\x84\xA8|\xF0\x9F\x84\xA9|\xF0\x9F\x84\xAA|\xF0\x9F\x84\xAB|\xF0\x9F\x84\xAC|\xF0\x9F\x84\xAD|\xF0\x9F\x84\xAE|\xF0\x9F\x84\xAF|\xF0\x9F\x84\xB0|\xF0\x9F\x84\xB1|\xF0\x9F\x84\xB2|\xF0\x9F\x84\xB3|\xF0\x9F\x84\xB4|\xF0\x9F\x84\xB5|\xF0\x9F\x84\xB6|\xF0\x9F\x84\xB7|\xF0\x9F\x84\xB8|\xF0\x9F\x84\xB9|\xF0\x9F\x84\xBA|\xF0\x9F\x84\xBB|\xF0\x9F\x84\xBC|\xF0\x9F\x84\xBD|\xF0\x9F\x84\xBE|\xF0\x9F\x84\xBF|\xF0\x9F\x85\x80|\xF0\x9F\x85\x81|\xF0\x9F\x85\x82|\xF0\x9F\x85\x83|\xF0\x9F\x85\x84|\xF0\x9F\x85\x85|\xF0\x9F\x85\x86|\xF0\x9F\x85\x87|\xF0\x9F\x85\x88|\xF0\x9F\x85\x89|\xF0\x9F\x85\x8A|\xF0\x9F\x85\x8B|\xF0\x9F\x85\x8C|\xF0\x9F\x85\x8D|\xF0\x9F\x85\x8E|\xF0\x9F\x85\x8F|\xF0\x9F\x85\x90|\xF0\x9F\x85\x91|\xF0\x9F\x85\x92|\xF0\x9F\x85\x93|\xF0\x9F\x85\x94|\xF0\x9F\x85\x95|\xF0\x9F\x85\x96|\xF0\x9F\x85\x97|\xF0\x9F\x85\x98|\xF0\x9F\x85\x99|\xF0\x9F\x85\x9A|\xF0\x9F\x85\x9B|\xF0\x9F\x85\x9C|\xF0\x9F\x85\x9D|\xF0\x9F\x85\x9E|\xF0\x9F\x85\x9F|\xF0\x9F\x85\xA0|\xF0\x9F\x85\xA1|\xF0\x9F\x85\xA2|\xF0\x9F\x85\xA3|\xF0\x9F\x85\xA4|\xF0\x9F\x85\xA5|\xF0\x9F\x85\xA6|\xF0\x9F\x85\xA7|\xF0\x9F\x85\xA8|\xF0\x9F\x85\xA9|\xF0\x9F\x85\xAA|\xF0\x9F\x85\xAB|\xF0\x9F\x85\xAC|\xF0\x9F\x85\xAD|\xF0\x9F\x85\xAE|\xF0\x9F\x85\xAF|\xF0\x9F\x85\xB0|\xF0\x9F\x85\xB1|\xF0\x9F\x85\xB2|\xF0\x9F\x85\xB3|\xF0\x9F\x85\xB4|\xF0\x9F\x85\xB5|\xF0\x9F\x85\xB6|\xF0\x9F\x85\xB7|\xF0\x9F\x85\xB8|\xF0\x9F\x85\xB9|\xF0\x9F\x85\xBA|\xF0\x9F\x85\xBB|\xF0\x9F\x85\xBC|\xF0\x9F\x85\xBD|\xF0\x9F\x85\xBE|\xF0\x9F\x85\xBF|\xF0\x9F\x86\x80|\xF0\x9F\x86\x81|\xF0\x9F\x86\x82|\xF0\x9F\x86\x83|\xF0\x9F\x86\x84|\xF0\x9F\x86\x85|\xF0\x9F\x86\x86|\xF0\x9F\x86\x87|\xF0\x9F\x86\x88|\xF0\x9F\x86\x89|\xF0\x9F\x86\x8A|\xF0\x9F\x86\x8B|\xF0\x9F\x86\x8C|\xF0\x9F\x86\x8D|\xF0\x9F\x86\x8E|\xF0\x9F\x86\x8F|\xF0\x9F\x86\x90|\xF0\x9F\x86\x91|\xF0\x9F\x86\x92|\xF0\x9F\x86\x93|\xF0\x9F\x86\x94|\xF0\x9F\x86\x95|\xF0\x9F\x86\x96|\xF0\x9F\x86\x97|\xF0\x9F\x86\x98|\xF0\x9F\x86\x99|\xF0\x9F\x86\x9A|\xF0\x9F\x86\x9B|\xF0\x9F\x86\x9C|\xF0\x9F\x86\x9D|\xF0\x9F\x86\x9E|\xF0\x9F\x86\x9F|\xF0\x9F\x86\xA0|\xF0\x9F\x86\xA1|\xF0\x9F\x86\xA2|\xF0\x9F\x86\xA3|\xF0\x9F\x86\xA4|\xF0\x9F\x86\xA5|\xF0\x9F\x86\xA6|\xF0\x9F\x86\xA7|\xF0\x9F\x86\xA8|\xF0\x9F\x86\xA9|\xF0\x9F\x86\xAA|\xF0\x9F\x86\xAB|\xF0\x9F\x86\xAC|\xF0\x9F\x86\xAD|\xF0\x9F\x87\xA6|\xF0\x9F\x87\xA7|\xF0\x9F\x87\xA8|\xF0\x9F\x87\xA9|\xF0\x9F\x87\xAA|\xF0\x9F\x87\xAB|\xF0\x9F\x87\xAC|\xF0\x9F\x87\xAD|\xF0\x9F\x87\xAE|\xF0\x9F\x87\xAF|\xF0\x9F\x87\xB0|\xF0\x9F\x87\xB1|\xF0\x9F\x87\xB2|\xF0\x9F\x87\xB3|\xF0\x9F\x87\xB4|\xF0\x9F\x87\xB5|\xF0\x9F\x87\xB6|\xF0\x9F\x87\xB7|\xF0\x9F\x87\xB8|\xF0\x9F\x87\xB9|\xF0\x9F\x87\xBA|\xF0\x9F\x87\xBB|\xF0\x9F\x87\xBC|\xF0\x9F\x87\xBD|\xF0\x9F\x87\xBE|\xF0\x9F\x87\xBF/g;
	@utfcount = grep defined, @utfcount; 
	my $code4 = scalar @utfcount;
	if ( $code4 >= 1 ) { 
		$code++; 
	}

	if ($code4 > 4) {
		my $score = $pms->{conf}->{chaos_tag};
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm Fraud Character Set: $code4";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    } elsif ($code > 1) {
		my $count = $code - 1;
		my $score = ($pms->{conf}->{chaos_tag} * log($code) * $count);
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm From Name Mixed Code Sets: $code";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}


=head2  check_for_url_shorteners()

=over 5

=item  This is a test of URIs in the message body, looking for URL Shortener services.  These services are grouped as Public (bit.ly, etc.) and Private (wpo.st, etc.).  The scoring of the rule, JR_PUBLIC_SHORTURL, is linear: ${chaos_tag} * 0.25 * $pubcount + $pubcount * 1.5.  The rule, JR_PRIVATE_SHORTURL is a callout for your use in Meta rules as needed.  It has a fixed score of 0.01.  For both rules, the Description contains a count of the number of Short URL links found. 
 

=back

=cut

sub check_for_url_shorteners {
    my ( $self, $pms ) = @_;
	my $uris = $pms->get_uri_detail_list();
	my $pubcount = 0;
	my $privcount = 0;
	while (my($uri, $info) = each %{$uris}) {
    next unless ($info->{domains});
    foreach ( keys %{ $info->{domains} } ) {
		if ( $uri =~  /https?:\/\/(.{1,15}\.)?(0rz\.tw|1l2\.us|1link\.in|1url\.com|1u\.ro|2big\.at|2chap\.it|2\.gp|2\.ly|2pl\.us|2su\.de|2tu\.us|2ze\.us|301\.to|301url\.com|307\.to|3\.ly|4ms\.me|4url\.cc|6url\.com|7\.ly|9mp\.com|a2a\.me|a2n\.eu|aa\.cx|abbr\.com|abcurl\.net|abe5\.com|access\.im|adf\.ly|adjix\.com|ad\.vu|afx\.cc|a\.gd|a\.gg|aim\.co\.id|all\.fuseurl\.com|alturl\.com|amishdatacenter\.com|amishprincess\.com|a\.nf|ar\.gy|arm\.in|arst\.ch|asso\.in|atu\.ca|aurls\.info|awe\.sm|ayl\.lv|azc\.cc|azqq\.com|b23\.ru|b2l\.me|b65\.com|b65\.us|back\.ly|bacn\.me|bc\.vc|bcool\.bz|beam\.to|bgl\.me|bin\.wf|binged\.it|bit\.do|bit\.ly|bitly\.com|bkite\.com|bl\.ink|blippr\.com|bloat\.me|blu\.cc|bon\.no|branch\.io|bsa\.ly|bt\.io|budurl\.com|buff\.ly|buk\.me|burnurl\.com|buzurl\.com|canurl\.com|catsnthing\.com|catsnthings\.fun|cc\.uz|cd4\.me|chatter\.com|chilp\.it|chopd\.it|chpt\.me|chs\.mx|chzb\.gr|clck\.ru|cliccami\.info|clickthru\.ca|cli\.gs|clicky\.me|clipurl\.us|clk\.im|clk\.my|cl\.lk|cl\.ly|clkim\.com|cloaky\.de|clop\.in|clp\.ly|coge\.la|c-o\.in|cokeurl\.com|conta\.cc|cort\.as|cot\.ag|crabrave\.pw|crks\.me|crum\.pl|c\.shamekh\.ws|ctvr\.us|cur\.lv|curio\.us|curiouscat\.club|cuthut\.com|cutt\.ly|cutt\.us|cuturl\.com|cuturls\.com|cutwin\.biz|db\.tt|decenturl\.com|deck\.ly|df9\.net|dfl8\.me|digbig\.com|digipills\.com|digs\.by|disçordapp\.com|dld\.bz|dlvr\.it|dn\.vc|doiop\.com|doi\.org|do\.my|dopen\.us|dr\.tl|drudge\.tw|durl\.me|durl\.us|dvlr\.it|dwarfurl\.com|easyuri\.com|easyurl\.net|ebay\.to|eca\.sh|eclurl\.com|eepurl\.com|eezurl\.com|erq\.io|eweri\.com|ewerl\.com|ezurl\.eu|fa\.by|faceto\.us|fav\.me|fbshare\.me|fff\.to|ff\.im|fhurl\.com|filoops\.info|fire\.to|firsturl\.de|firsturl\.net|flic\.kr|flingk\.com|flq\.us|fly2\.ws|fn\.tc|fon\.gs|forms\.gle|formspring\.me|fortnight\.space|fortnitechat\.site|foxyurl\.com|freak\.to|freegiftcards\.co|fur\.ly|fuseurl\.com|fuzzy\.to|fw\.to|fwd4\.me|fwdurl\.net|fwib\.net|g8l\.us|gameptp\.com|get\.sh|get-shorty\.com|get-url\.com|geturl\.us|gg\.gg|gi\.vc|gizmo\.do|gkurl\.us|gl\.am|go2\.me|go2l\.ink|go\.9nl\.com|gog\.li|go\.ign\.com|goo\.gl|golmao\.com|good\.ly|goshrink\.com|go\.to|gowal\.la|gplinks\.in|gplus\.to|grabify\.link|gri\.ms|g\.ro\.lt|gurl\.es|hao\.jp|heg\.tc|hellotxt\.com|hex\.io|hfs\.rs|hiderefer\.com|hmm\.ph|hopclicks\.com|hop\.im|hotredirect\.com|hotshorturl\.com|href\.in|hsblinks\.com|ht\.ly|htxt\.it|hub\.am|hugeurl\.com|hulu\.com|hurl\.it|hurl\.me|hurl\.no|hurl\.ws|icanhaz\.com|icio\.us|idek\.net|ikr\.me|ilix\.in|inx\.lv|ir\.pe|irt\.me|iscool\.net|is\.gd|it2\.in|ito\.mx|its\.my|itsy\.it|ity\.im|ix\.lt|j2j\.de|jdem\.cz|jijr\.com|j\.mp|joinmy\.site|just\.as|k6\.kz|ketkp\.in|kisa\.ch|kissa\.be|kl\.am|klck\.me|kore\.us|korta\.nu|ko\.tc|kots\.nu|krunchd\.com|krz\.ch|ktzr\.us|kurl\.ng|kutt\.it|k\.vu|kxk\.me|l9k\.net|lat\.ms|l\.hh\.de|lc\.chat|lihi\.cc|liip\.to|liltext\.com|lin\.cr|lin\.io|link\.zip\.net|linkbee\.com|linkbun\.ch|linkee\.com|linkgap\.com|linkslice\.com|linktr\.ee|linxfix\.de|liteurl\.net|liurl\.cn|livesi\.de|lix\.in|lk\.ht|lnk\.by|lnk\.cm|lnk\.gd|lnk\.in|lnk\.ly|lnk\.sk|lnkurl\.com|lnnk\.in|ln-s\.net|ln-s\.ru|lol\.tc|loopt\.us|lost\.in|l\.pr|lru\.jp|lt\.tl|lurl\.no|lu\.to|m2\.tc|macte\.ch|mash\.to|mavrev\.com|memurl\.com|merky\.de|metamark\.net|migre\.me|min2\.me|minecräft\.com|minilien\.com|minilink\.org|miniurl\.com|minurl\.fr|mke\.me|mmo\.tc|moby\.to|moourl\.com|mrte\.ch|msg\.sg|murl\.kz|mv2\.me|myloc\.me|mysp\.in|myurl\.in|myurl\.si|nanoref\.com|nanourl\.se|nbc\.co|nblo\.gs|nbx\.ch|ncane\.com|ndurl\.com|ne1\.net|netnet\.me|netshortcut\.com|nig\.gr|ni\.to|nm\.ly|nn\.nf|notlong\.com|not\.my|n\.pr|nsfw\.in|nutshellurl\.com|nxy\.in|nyti\.ms|oboeyasui\.com|oc1\.us|offur\.com|ofl\.me|o\.ly|omf\.gd|om\.ly|omoikane\.net|on\.cnn\.com|onecent\.us|onforb\.es|on\.mktw\.net|onsaas\.info|ooqx\.com|orz\.se|ouo\.io|owl\.li|ow\.ly|o-x\.fr|oxyz\.info|p8g\.tw|packetlivesmatter\.club|packetlivesmatter\.online|parv\.us|paulding\.net|pduda\.mobi|peaurl\.com|pendek\.in|pep\.si|pic\.gd|piko\.me|ping\.fm|piurl\.com|pli\.gs|plumurl\.com|plurk\.com|plurl\.me|p\.ly|po\.st|poll\.fm|polr\.me|pop\.ly|poprl\.com|posted\.at|post\.ly|poweredbydialup\.club|poweredbydialup\.online|poweredbydialup\.org|poweredbysecurity\.online|poweredbysecurity\.org|pp\.gg|prettylinkpro\.com|profile\.to|pt2\.me|ptiturl\.com|pub\.vitrue\.com|puke\.it|pvp\.tc|pysper\.com|qik\.li|qlnk\.net|qoiob\.com|qqc\.co|qr\.ae|qr\.cx|qr\.net|qte\.me|quickurl\.co\.uk|qurl\.com|qurlyq\.com|qu\.tc|quu\.nu|qux\.in|qy\.fi|rb6\.me|rb\.gy|rde\.me|read\.bi|readthis\.ca|reallytinyurl\.com|redir\.ec|redirects\.ca|redirx\.com|relyt\.us|retwt\.me|reurl\.cc|rickroll\.it|r\.im|ri\.ms|rivva\.de|riz\.gd|rly\.cc|rnk\.me|rsmonkey\.com|rt\.nu|rubyurl\.com|ru\.ly|rurl\.org|rww\.tw|s2r\.co|s\.gnoss\.us|s\.id|s3nt\.com|s4c\.in|s7y\.us|safelinks\.ru|safe\.mn|sai\.ly|sameurl\.com|scrnch\.me|sdut\.us|sed\.cx|sfu\.ca|shadyurl\.com|shar\.es|shim\.net|shink\.de|shorl\.com|short\.cm|shortenurl\.com|shorten\.ws|shorterlink\.com|short\.ie|shortener\.cc|shortio\.com|shortlinks\.co\.uk|shortly\.nl|shortna\.me|shortn\.me|shortr\.me|short\.to|shorturl\.at|shorturl\.com|shortz\.me|shoturl\.us|shout\.to|show\.my|shredurl\.com|shrinkify\.com|shrinkr\.com|shrinkster\.com|shrinkurl\.us|shrten\.com|shrt\.fr|shrtl\.com|shrtn\.com|shrtnd\.com|shrt\.st|shrt\.ws|shrunkin\.com|shurl\.net|shw\.me|simurl\.com|simurl\.net|simurl\.org|simurl\.us|sitelutions\.com|siteo\.us|slate\.me|slidesha\.re|slki\.ru|sl\.ly|smallr\.com|smallr\.net|smarturl\.it|smfu\.in|smsh\.me|smurl\.com|smurl\.name|snadr\.it|sn\.im|snipie\.com|snip\.ly|snipr\.com|snipurl\.com|snkr\.me|snurl\.com|sn\.vc|song\.ly|soo\.gd|sp2\.ro|spedr\.com|spottyfly\.com|sqze\.it|srnk\.net|sro\.tc|srs\.li|starturl\.com|stickurl\.com|stopify\.co|stpmvt\.com|sturly\.com|su\.pr|surl\.co\.uk|surl\.hu|surl\.it|t2m\.io|ta\.gd|takemyfile\.com|tbd\.ly|t\.cn|tcrn\.ch|tek\.link|tgr\.me|tgr\.ph|th8\.us|thecow\.me|thrdl\.es|tighturl\.com|timesurl\.at|tiniuri\.com|tini\.us|tinyarro\.ws|tiny\.cc|tiny\.ie|tinylink\.com|tinylink\.in|tiny\.ly|tiny\.pl|tinypl\.us|tinysong\.com|tinytw\.it|tinyuri\.ca|tinyurl\.com|tl\.gd|t\.lh\.com|tllg\.net|t\.ly|tmi\.me|tncr\.ws|tnij\.org|tnw\.to|tny\.com|togoto\.us|to\.je|to\.ly|totc\.us|to\.vg|toysr\.us|tpm\.ly|traceurl\.com|trackurl\.it|tra\.kz|trcb\.me|trg\.li|trib\.al|trick\.ly|trii\.us|tr\.im|trim\.li|tr\.my|trumpink\.lt|trunc\.it|truncurl\.com|tsort\.us|tubeurl\.com|turo\.us|tw0\.us|tw1\.us|tw2\.us|tw5\.us|tw6\.us|tw8\.us|tw9\.us|twa\.lk|tweetburner\.com|tweetl\.com|tweez\.me|twhub\.com|twi\.gy|twip\.us|twirl\.at|twit\.ac|twitclicks\.com|twitterurl\.net|twitterurl\.org|twitthis\.com|twittu\.ms|twiturl\.de|twitvid\.com|twitzap\.com|twixar\.me|twlv\.net|twtr\.us|twurl\.cc|twurl\.nl|u\.bb|u76\.org|ub0\.cc|uiop\.me|ulimit\.com|ulu\.lu|u\.mavrev\.com|um\.lk|unfaker\.it|u\.nu|updating\.me|ur1\.ca|urizy\.com|url360\.me|url4\.click|url\.ag|urlao\.com|url\.az|urlbee\.com|urlborg\.com|urlbrief\.com|urlcorta\.es|url\.co\.uk|urlcover\.com|urlcut\.com|urlcutter\.com|urlenco\.de|urlg\.info|url\.go\.it|urlhawk\.com|url\.ie|url\.inc-x\.eu|urlin\.it|urli\.nl|urlkiss\.com|url\.lotpatrol\.com|urloo\.com|urlpire\.com|urlshorteningservicefortwitter\.com|urls\.im|urltea\.com|urlu\.ms|urlvi\.b|urlvi\.be|urlx\.ie|ur\.ly|urlz\.at|urlzen\.com|urlzs\.com|usat\.ly|use\.my|uservoice\.com|ustre\.am|utfg\.sk|u\.to|v\.gd|v\.ht|vado\.it|vai\.la|vb\.ly|vdirect\.com|vgn\.am|viigo\.im|vi\.ly|virl\.com|viralurl\.com|vl\.am|vm\.lc|voizle\.com|vzturl\.com|vtc\.es|w0r\.me|w33\.us|w34\.us|w3t\.org|w55\.de|wa9\.la|wapo\.st|webalias\.com|welcome\.to|wh\.gov|widg\.me|virl\.ws|wipi\.es|wkrg\.com|woo\.ly|wow\.link|wp\.me|x\.co|xeeurl\.com|x\.hypem\.com|xil\.in|xlurl\.de|xr\.com|xrl\.in|xrl\.us|xrt\.me|x\.se|xurl\.es|xurl\.jp|x\.vu|xxs\.yt|xxsurl\.de|xzb\.cc|y\.ahoo\.it|yatuc\.com|ye\.pe|yep\.it|ye-s\.com|yfrog\.com|yhoo\.it|yiyd\.com|yko\.io|yourls\.org|yourtube\.site|youshouldclick\.us|youtubeshort\.pro|youtubeshort\.watch|yuarel\.com|yyv\.co|z0p\.de|zapt\.in|zi\.ma|zi\.me|zi\.mu|zi\.pe|zip\.li|zipmyurl\.com|zite\.to|zootit\.com|z\.pe|zud\.me|zurl\.ws|zzang\.kr|zz\.gd)\/.+/i ) {
			$pubcount++;
		}
		# Private shorteners for company use/non-public: Tumblr, Wash Post,
		# France news, You Tube, Amazon, USA Gov, Bravo TV, LinkedIn, McAfee,
		# OReilly, Politico, Digg, Twitter, 4 Square, Daily Motion, Facebook,
		# Disqus, Deals Plus, Apache Org, SharePoint/Office URLs,
		# Business Journals, Huffington Post, The Onion, Microsoft
		if ( $uri =~  /https?:\/\/(.{1,15}\.)?(tumblr\.com|wpo\.st|url4\.eu|youtu\.be|amzn\.com|amzn\.to|go\.usa\.gov|bravo\.ly|lnkd\.in|mcaf\.ee|oreil\.ly|politi\.co|digg\.com|t\.co|4sq\.com|dai\.ly|fb\.me|disq\.us|dealspl\.us|s\.apache\.org|surl\.link|surl\.ms|officeurl\.com|bizj\.us|huff\.to|onion\.com|aka\.ms)\/.+/i ) {
			$privcount++;
		}
    }
  }

    my $set = 0;
	my $score = 0;
	

    if ($pubcount >= 1) {
		my $rulename = "JR_PUBLIC_SHORTURL";
		$score = $pms->{conf}->{chaos_tag} * 0.25 * $pubcount + $pubcount * 1.5;
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $pubcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "BODY: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }
	
	if ($privcount >= 1) {
		my $rulename = "JR_PRIVATE_SHORTURL";
		$score = 0.01;
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm dynamic score. Count: $privcount";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "BODY: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head2  check_php_script()

=over 5

=item  This is a check for miscreant X-PHP-Originating-Script headers.  The rule JR_PHP_SCRIPT is set when a header match is detected.  Scores vary, depending upon the PHP script used to send the message.

=back

=cut


sub check_php_script {
    my ( $self, $pms ) = @_;
	my $pmail = $pms->get('X-PHP-Originating-Script');
	my $set = 0;
	my $score = 0;
	my $rulename = "JR_PHP_SCRIPT";
	if ( $pmail =~	/[0-9]{2,8}:([A-Z]{7}\.php|[0-9]{1,4}\.php)/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/[0-9]{2,8}:scomxqvjfkpmgpjc\.php/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/[0-9]{2,8}:st\.php/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/eval\(\)\'d\scode/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/zebi\.php/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/(1{2,5}|2{2,5}|3{2,5}|4{2,5}|5{2,5}|6{2,5}|7{2,5}|8{2,5}|9{2,5}|0{2,5})\.php/g ) {
		$count++;
		$score = 0.5 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/sendEmail/g ) {
		$score = 0.2 * $pms->{conf}->{chaos_tag};
	} elsif ( $pmail =~	/[0-9]{2,7}:Sendmail\.php/g ) {
		$count++;
		$score = -0.2 * $pms->{conf}->{chaos_tag};
	}

    if ($count > 0) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm PHP Script Detections";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head2  id_attachments()

=over 5

=item  This is a check of the 'Content-Type' MIME headers for potentially bad attachments.  These include Archive, MS Office/Works, RTF, PDF, Boot Image, Executable Program, and HTML, file attachments.  These are Callouts, and each have a score of 0.01.

    + JR_ATTACH_ARCHIVE         + JR_ATTACH_RTF
    + JR_ATTACH_PDF             + JR_ATTACH_BOOTIMG
    + JR_ATTACH_MSOFFICE        + JR_ATTACH_EXEC
    + JR_ATTACH_OPENOFFICE      + JR_ATTACH_HTML
    + JR_ATTACH_RISK

=item  JR_ATTACH_RISK is rule that is also set if ANY (OR) of the above rules are matched.  Useful in conjunction with Body phrase checks for "Open Me", "Click This" schemes.  

=back

=over 5

=item  The following rules are specific callouts for JPG, ZIP, and GZ files.  The callout rule, JR_ATTACH_IMAGE, is set when ANY common image attachment is detected.

    + JR_ATTACH_ZIP             + JR_ATTACH_GZIP
    + JR_ATTACH_JPEG            + JR_ATTACH_IMAGE

=back

=over 5

=item  There is one scoring rule that matches if an attachment filename equals the message's Subject.  This is scored at 0.58 * {chaos_tag}.

    + JR_SUBJ_ATTACH_NAME
	
=back

=cut

sub id_attachments {
    my ( $self, $pms ) = @_;
	my $rulename = "";
	my $ruledesc = "";
	my $file = "";
	my $count = 0;
	my $acount = 0;
	my $pcount = 0;
	my $mcount = 0;
	my $rcount = 0;
	my $bcount = 0;
	my $ecount = 0;
	my $hcount = 0;
	my $icount = 0;
	my $jcount = 0;
	my $zipcount = 0;
	my $gzcount = 0;
	my $set = 0;
	my $score = 0.01;
	my $subject = $pms->get('Subject');
	chomp $subject;
	my $msg = $pms->get_message();

	# print Dumper($test);
    # Mail::SpamAssassin::PerMsgStatus::enter_helper_run_mode($self);

	# foreach my $p ($pms->{msg}->find_parts(qr/./)) {
	 my @types = (
        qr(application/x-tar)i,
        qr(application/zip)i,
		qr(application/x-gzip)i,
		qr(application/x-gtar)i,
		qr(application/x-compressed)i,
		qr(application/x-compress)i,
		qr(application/x-cpio)i,
		qr(application/x-bcpio)i,
		qr(application/x-rar-compressed)i,
		qr(application/x-bzip)i,
		qr(application/x-bzip2)i,
		qr(application/java-archive)i,
		qr(application/x-stuffit)i,
        qr(application/pdf)i,
		qr(application/msword)i,
        qr(application/vnd.openxmlformats-officedocument.wordprocessingml.document)i,
        qr(application/vnd.openxmlformats-officedocument.wordprocessingml.template)i,
        qr(application/vnd.ms-word.document.macroEnabled.12)i,
        qr(application/vnd.ms-word.template.macroEnabled.12)i,
		qr(application/vnd.ms-excel)i,
		qr(application/vnd.openxmlformats-officedocument.spreadsheetml.sheet)i,
		qr(application/vnd.openxmlformats-officedocument.spreadsheetml.template)i,
		qr(application/vnd.ms-excel.sheet.macroEnabled.12)i,
		qr(application/vnd.ms-excel.template.macroEnabled.12)i,
		qr(application/vnd.ms-excel.addin.macroEnabled.12)i,
		qr(application/vnd.ms-excel.sheet.binary.macroEnabled.12)i,
		qr(application/vnd.ms-powerpoint)i,
		qr(application/vnd.openxmlformats-officedocument.presentationml.presentation)i,
		qr(application/vnd.openxmlformats-officedocument.presentationml.template)i,
		qr(application/vnd.openxmlformats-officedocument.presentationml.slideshow)i,
		qr(application/vnd.ms-powerpoint.addin.macroEnabled.12)i,
		qr(application/vnd.ms-powerpoint.presentation.macroEnabled.12)i,
		qr(application/vnd.ms-powerpoint.template.macroEnabled.12)i,
		qr(application/vnd.ms-powerpoint.slideshow.macroEnabled.12)i,
		qr(application/vnd.ms-access)i,
		qr(application/vnd.ms-project)i,
		qr(application/vnd.ms-works)i,
		qr(application/rtf)i,
		qr(application/vnd.oasis.opendocument.text)i,
		qr(application/vnd.oasis.opendocument.text-template)i,
		qr(application/vnd.oasis.opendocument.text-web)i,
		qr(application/vnd.oasis.opendocument.text-master)i,
		qr(application/vnd.oasis.opendocument.graphics)i,
		qr(application/vnd.oasis.opendocument.graphics-template)i,
		qr(application/vnd.oasis.opendocument.presentation)i,
		qr(application/vnd.oasis.opendocument.presentation-template)i,
		qr(application/vnd.oasis.opendocument.spreadsheet)i,
		qr(application/vnd.oasis.opendocument.spreadsheet-template)i,
		qr(application/vnd.oasis.opendocument.chart)i,
		qr(application/vnd.oasis.opendocument.formula)i,
		qr(application/vnd.oasis.opendocument.database)i,
		qr(application/vnd.oasis.opendocument.image)i,
		qr(application/vnd.openofficeorg.extension)i,
		qr(application/mac-binhex40)i,
		qr(application/hta)i,
		qr(application/winhlp)i,
		qr(image/jpeg)i,
		qr(image/png)i,
		qr(image/gif)i,
		qr(image/bmp)i,
		qr(image/tiff)i,
		qr(image/svg+xml)i,
		qr(image/wmf)i,
		qr(image/emf)i,
		qr(text/html)i,
		qr(application/octet-stream)i
    );
	
	foreach my $type ( @types ) {
        foreach my $p ( $msg->find_parts($type) ) {
		    
			$file = $p->{'name'};
			
			if ( ! defined $file ) {
				next;
			}
			# my ($filename1,$ext) = split(/\./, $file); 
			# Does not pick up filenames with losts of dots in them
			# Change Request.01.13.2021.pdf
			my $filename1 = $file;
			# This works to pick up the last dot in a filename:
			$filename1 =~ s/(.)\.[^.]+$/$1/x;
				# s/
                # (.)             # matches any character
                # \.              # the literal dot starting an extension
                # [^.]+           # one or more NON-dots
                # $               # end of the string
				# /$1/x;
			# OK.  I'm here.  Quick hack to check if the Subject = PDF
			# name (Aaron Smith Sextortion payload).  Still, this 
			# appears in normal mail.
			if ( $filename1 eq $subject ) {
				my $rulename1 = "JR_SUBJ_ATTACH_NAME";
				my $ruledesc1 = "Subject is Filename";
				my $score1 = 0.58 * $pms->{conf}->{chaos_tag};
				my $description = $pms->{conf}->{descriptions}->{"$rulename1"};
				$description .= "CHAOS.pm $ruledesc1";
				# $description .= "CHAOS.pm detection: $file";
				$pms->{conf}->{descriptions}->{"$rulename1"} = $description;
				$pms->got_hit("$rulename1", "BODY: ", score => $score1);
				$pms->{conf}->{scoreset}->[$set]->{"$rulename1"} = sprintf("%0.3f", $score1);
			}
			# print Dumper($p);

			if ( $file =~ /.*(\.tgz|\.zip|\.xz|\.z|\.x\-rar|\.jar|\.r00|\.arc|\.gz|\.bz|\.bz2|\.tar|\.cpio|\.bcpio|\.sit|\.lzh|\.lha|\.r09)\"?/gi ) {
				$rulename = "JR_ATTACH_ARCHIVE";
				$ruledesc = "Archive attachment";
				if ( $acount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$acount++;
				}
				if (( $zipcount == 0 ) && ( $file =~ /.*(\.zip)\"?/gi )) {
				    $rulename = "JR_ATTACH_ZIP";
					$ruledesc = "ZIP attachment";
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$zipcount++;
				}
				if (( $gzcount == 0 ) && ( $file =~ /.*(\.gz)\"?/gi )) {
				    $rulename = "JR_ATTACH_GZIP";
					$ruledesc = "GZIP attachment";
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$gzcount++;
				}
					
			} elsif ( $file =~ /.*([\._]pdf\.img|\.pdf)\"?/gi ) {
				$rulename = "JR_ATTACH_PDF";
				$ruledesc = "PDF attachment";
				if ( $pcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					# $description .= "CHAOS.pm:$filename1";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$pcount++;
					
				}
			} elsif ( $file =~ /.*(\.doc|\.dot|\.docx|\.dotx|\.docm|\.dotm|\.xls|\.xlt|\.xla|\.xlw|\.xlc|\.xlsx|\.xltx|\.xlsm|\.xltm|\.xlam|\.xlsb|\.ppt|\.pps|\.ppa|\.pot|\.pptx|\.potx|\.ppsx|\.ppam|\.pptm|\.potm|\.ppsm|\.mdb|\.mpp|\.wcm|\.wdb|\.wks|\.wps)\"?/gi ) {
				$rulename = "JR_ATTACH_MSOFFICE";
				$ruledesc = "Microsoft Attachment";
				if ( $mcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$mcount++;
				}
			} elsif ( $file =~ /.*(\.odt|\.ott|\.oth|\.odm|\.odg|\.otg|\.odp|\.otp|\.ods|\.ots|\.odc|\.odf|\.odb|\.odi|\.oxt)\"?/gi ) {
				$rulename = "JR_ATTACH_OPENOFFICE";
				$ruledesc = "OpenOffice Attachment";
				if ( $mcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$mcount++;
				}
			} elsif ( $file =~ /.*(\.rtf)\"?/gi ) {
				$rulename = "JR_ATTACH_RTF";
				$ruledesc = "RTF attachment";
				if ( $rcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$rcount++;
				}
			} elsif ( $file =~ /.*(\.iso|\.img|\.daa|\.dwg)\"?/gi ) {
				$rulename = "JR_ATTACH_BOOTIMG";
				$ruledesc = "Boot image attachment";
				if ( $bcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$bcount++;
				}
			} elsif ( $file =~ /.*(\.exe|\.hqx|\.cmd|\.bin|\.hta|\.hlp|\.pif|\.class|\.dll|\.msi)\"?/gi ) {
				$rulename = "JR_ATTACH_EXEC";
				$ruledesc = "Executable attachment";
				if ( $ecount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$ecount++;
				}
			} elsif ( $file =~ /.*(\.htm|\.html)\"?/i ) {
				$rulename = "JR_ATTACH_HTML";
				$ruledesc = "HTML file attachment";
				if ( $hcount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
					$hcount++;
				}
			} elsif ( $file =~ /.*(\.jpe|\.jpeg|\.jpg|\.bmp|\.gif|\.svg|\.tif|\.tiff|\.wmf|\.emf|\.png)\"?/gi ) {
				$rulename = "JR_ATTACH_IMAGE";
				$ruledesc = "Image attachment";
				if ( $icount == 0 ) { 
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score);
					$icount++;
				}
				if (( $jcount == 0 ) && ( $file =~ /.*(\.jpe|\.jpg|\.jpeg)\"?/gi )) {
					$rulename = "JR_ATTACH_JPEG";
					$ruledesc = "JPEG Image";
					my $description = $pms->{conf}->{descriptions}->{"$rulename"};
					$description .= "CHAOS.pm detection: $ruledesc";
					$pms->{conf}->{descriptions}->{"$rulename"} = $description;
					$pms->got_hit("$rulename", "BODY: ", score => $score);
					$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
					$jcount++;
				}
			}
				
		}
	}

	$count = $acount + $pcount + $mcount + $rcount + $bcount + $ecount + $hcount;
    if ( $count >= 1 ) {
		$rulename = "JR_ATTACH_RISK";
		$ruledesc = "Dangerous file";
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm detection: $ruledesc";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "BODY: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head2  first_name_basis()

=over 5

=item  This tests the From Name field for the use of a single First Name.  The match includes some first name variants, like "Mr. Jared", "Jared at home", or First Name and Last Initial.  If found, rule JR_FRM_FRSTNAME is set and scored at: 0.3 * ${chaos_tag}.

=back

=cut

sub first_name_basis {
    my ( $self, $pms ) = @_;
	my $set = 0;
	my $count = 0;
	my $score = 0.3 * $pms->{conf}->{chaos_tag};
	my $rulename = "JR_FRM_1STNAME";
	local $fname1 = "";
	local $fname2 = "";
	local $fname3 = "";
	local $fname4 = "";
	local $fname_plus = "";

    my $from = $pms->get('From:name');
	&fname_match();
	if ( $from =~ /^($fname1)($|[\s\.][A-Z]\.?$|(\s(from|at|of|in|on|here)\s))/i ) {
		$count++;
	} elsif ( $from =~ /^($fname2)($|[\s\.][A-Z]\.?$|(\s(from|at|of|in|on|here)\s))/i ) {
		$count++;
	} elsif ( $from =~ /^($fname3)($|[\s\.][A-Z]\.?$|(\s(from|at|of|in|on|here)\s))/i ) {
		$count++;
	} elsif ( $from =~ /^($fname4)($|[\s\.][A-Z]\.?$|(\s(from|at|of|in|on|here)\s))/i ) {
		$count++;
	} elsif ( $from =~ /^($fname_plus)[\.\,]\s($fname1)$/i ) {
		$count++;
	} elsif ( $from =~ /^($fname_plus)[\.\,]\s($fname2)$/i ) {
		$count++;
	} elsif ( $from =~ /^($fname_plus)[\.\,]\s($fname3)$/i ) {
		$count++;
	} elsif ( $from =~ /^($fname_plus)[\.\,]\s($fname4)$/i ) {
		$count++;
	}
		
    if ($count >= 1) {
		my $description = $pms->{conf}->{descriptions}->{"$rulename"};
		$description .= "CHAOS.pm From 1st-Name Only";
		$pms->{conf}->{descriptions}->{"$rulename"} = $description;
		$pms->got_hit("$rulename", "HEADER: ", score => $score);
		$pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.3f", $score); 
    }

return 0;
}

=head1  MORE DOCUMENTATION

=over 5

=item  See also <https://spamassassin.apache.org/> and <https://wiki.apache.org/spamassassin/> for more information.  

=back

=over 5

=item  See this project's Wiki for more informaton: https://github.com/telecom2k3/CHAOS/wiki/ 

=back

=head1  SEE ALSO

=over 5

=item  Mail::SpamAssassin::Conf(3) 

=item  Mail::SpamAssassin::PerMsgStatus(3) 

=item  Mail::SpamAssassin::Plugin

=back

=head1  BUGS

=over 5

=item  While I do follow the SA-User's List, please do NOT report bugs there.

=item  If at all possible, please use the issue tracker at GitHub to report problems and request any additional features:  https://github.com/telecom2k3/CHAOS/issues  

=item  You can also report the problem by E-Mail.  See the AUTHOR section for contact information.

=back

=head1 AUTHOR

=over 5

=item  Jared Hall, <jared@jaredsec.com> or <telecom2k3@gmail.com>

=back

=head1  CAVEATS

=over 5

=item  Tuorum Periculo: If an Eval rule provided in this plugin does not meet the requirements of you or your clients, please disable the rule and report the problem.  See the BUGS section for information regarding problem reporting.

=back

=over 5

=item  The author does NOT accept any liability whatever for YOUR use of this software. Use at your own risk! 

=back

=head1  COPYRIGHT

=over 5

=item  CHAOS.pm is distributed under the MIT License as described in the LICENSE file included.  Copyright (c) 2021 Jared Hall

=back

=head1  AVAILABILITY

=over 5

=item  Visit the project's site for the latest updates: https://github.com/telecom2k3/CHAOS/

=back

=cut



sub emoji_hunt {

	$jr_line1 = qr/\xF0\x9F\x98\x80|\xF0\x9F\x98\x81|\xF0\x9F\x98\x82|\xF0\x9F\x98\x83|\xF0\x9F\x98\x84|\xF0\x9F\x98\x85|\xF0\x9F\x98\x86|\xF0\x9F\x98\x87|\xF0\x9F\x98\x88|\xF0\x9F\x98\x89|\xF0\x9F\x98\x8A|\xF0\x9F\x98\x8B|\xF0\x9F\x98\x8C|\xF0\x9F\x98\x8D|\xF0\x9F\x98\x8E|\xF0\x9F\x98\x8F|\xF0\x9F\x98\x90|\xF0\x9F\x98\x91|\xF0\x9F\x98\x92|\xF0\x9F\x98\x93|\xF0\x9F\x98\x94|\xF0\x9F\x98\x95|\xF0\x9F\x98\x96|\xF0\x9F\x98\x97|\xF0\x9F\x98\x98|\xF0\x9F\x98\x99|\xF0\x9F\x98\x9A|\xF0\x9F\x98\x9B|\xF0\x9F\x98\x9C|\xF0\x9F\x98\x9D|\xF0\x9F\x98\x9E|\xF0\x9F\x98\x9F|\xF0\x9F\x98\xA0|\xF0\x9F\x98\xA1|\xF0\x9F\x98\xA2|\xF0\x9F\x98\xA3|\xF0\x9F\x98\xA4|\xF0\x9F\x98\xA5|\xF0\x9F\x98\xA6|\xF0\x9F\x98\xA7|\xF0\x9F\x98\xA8|\xF0\x9F\x98\xA9|\xF0\x9F\x98\xAA|\xF0\x9F\x98\xAB|\xF0\x9F\x98\xAC|\xF0\x9F\x98\xAD|\xF0\x9F\x98\xAE|\xF0\x9F\x98\xAF|\xF0\x9F\x98\xB0|\xF0\x9F\x98\xB1|\xF0\x9F\x98\xB2|\xF0\x9F\x98\xB3|\xF0\x9F\x98\xB4|\xF0\x9F\x98\xB5|\xF0\x9F\x98\xB6|\xF0\x9F\x98\xB7|\xF0\x9F\x98\xB8|\xF0\x9F\x98\xB9|\xF0\x9F\x98\xBA|\xF0\x9F\x98\xBB|\xF0\x9F\x98\xBC|\xF0\x9F\x98\xBD|\xF0\x9F\x98\xBE|\xF0\x9F\x98\xBF|\xF0\x9F\x99\x80|\xF0\x9F\x99\x81|\xF0\x9F\x99\x82|\xF0\x9F\x99\x83|\xF0\x9F\x99\x84|\xF0\x9F\x99\x85|\xF0\x9F\x99\x86|\xF0\x9F\x99\x87|\xF0\x9F\x99\x88|\xF0\x9F\x99\x89|\xF0\x9F\x99\x8A|\xF0\x9F\x99\x8B|\xF0\x9F\x99\x8C|\xF0\x9F\x99\x8D|\xF0\x9F\x99\x8E|\xF0\x9F\x99\x8F|\xF0\x9F\x8C\x80|\xF0\x9F\x8C\x81|\xF0\x9F\x8C\x82|\xF0\x9F\x8C\x83|\xF0\x9F\x8C\x84|\xF0\x9F\x8C\x85|\xF0\x9F\x8C\x86|\xF0\x9F\x8C\x87|\xF0\x9F\x8C\x88|\xF0\x9F\x8C\x89|\xF0\x9F\x8C\x8A|\xF0\x9F\x8C\x8B|\xF0\x9F\x8C\x8C|\xF0\x9F\x8C\x8D|\xF0\x9F\x8C\x8E|\xF0\x9F\x8C\x8F|\xF0\x9F\x8C\x90|\xF0\x9F\x8C\x91|\xF0\x9F\x8C\x92|\xF0\x9F\x8C\x93|\xF0\x9F\x8C\x94|\xF0\x9F\x8C\x95|\xF0\x9F\x8C\x96|\xF0\x9F\x8C\x97|\xF0\x9F\x8C\x98|\xF0\x9F\x8C\x99|\xF0\x9F\x8C\x9A|\xF0\x9F\x8C\x9B|\xF0\x9F\x8C\x9C|\xF0\x9F\x8C\x9D|\xF0\x9F\x8C\x9E|\xF0\x9F\x8C\x9F|\xF0\x9F\x8C\xA0|\xF0\x9F\x8C\xA1|\xF0\x9F\x8C\xA2|\xF0\x9F\x8C\xA3|\xF0\x9F\x8C\xA4|\xF0\x9F\x8C\xA5|\xF0\x9F\x8C\xA6|\xF0\x9F\x8C\xA7|\xF0\x9F\x8C\xA8|\xF0\x9F\x8C\xA9|\xF0\x9F\x8C\xAA|\xF0\x9F\x8C\xAB|\xF0\x9F\x8C\xAC|\xF0\x9F\x8C\xAD|\xF0\x9F\x8C\xAE|\xF0\x9F\x8C\xAF|\xF0\x9F\x8C\xB0|\xF0\x9F\x8C\xB1|\xF0\x9F\x8C\xB2|\xF0\x9F\x8C\xB3|\xF0\x9F\x8C\xB4|\xF0\x9F\x8C\xB5|\xF0\x9F\x8C\xB6|\xF0\x9F\x8C\xB7|\xF0\x9F\x8C\xB8|\xF0\x9F\x8C\xB9|\xF0\x9F\x8C\xBA|\xF0\x9F\x8C\xBB|\xF0\x9F\x8C\xBC|\xF0\x9F\x8C\xBD|\xF0\x9F\x8C\xBE|\xF0\x9F\x8C\xBF|\xF0\x9F\x8D\x80|\xF0\x9F\x8D\x81|\xF0\x9F\x8D\x82|\xF0\x9F\x8D\x83|\xF0\x9F\x8D\x84|\xF0\x9F\x8D\x85|\xF0\x9F\x8D\x86|\xF0\x9F\x8D\x87|\xF0\x9F\x8D\x88|\xF0\x9F\x8D\x89|\xF0\x9F\x8D\x8A|\xF0\x9F\x8D\x8B|\xF0\x9F\x8D\x8C|\xF0\x9F\x8D\x8D|\xF0\x9F\x8D\x8E|\xF0\x9F\x8D\x8F|\xF0\x9F\x8D\x90|\xF0\x9F\x8D\x91|\xF0\x9F\x8D\x92|\xF0\x9F\x8D\x93|\xF0\x9F\x8D\x94|\xF0\x9F\x8D\x95|\xF0\x9F\x8D\x96|\xF0\x9F\x8D\x97|\xF0\x9F\x8D\x98|\xF0\x9F\x8D\x99|\xF0\x9F\x8D\x9A|\xF0\x9F\x8D\x9B|\xF0\x9F\x8D\x9C|\xF0\x9F\x8D\x9D|\xF0\x9F\x8D\x9E|\xF0\x9F\x8D\x9F|\xF0\x9F\x8D\xA0|\xF0\x9F\x8D\xA1|\xF0\x9F\x8D\xA2|\xF0\x9F\x8D\xA3|\xF0\x9F\x8D\xA4|\xF0\x9F\x8D\xA5|\xF0\x9F\x8D\xA6|\xF0\x9F\x8D\xA7|\xF0\x9F\x8D\xA8|\xF0\x9F\x8D\xA9|\xF0\x9F\x8D\xAA|\xF0\x9F\x8D\xAB|\xF0\x9F\x8D\xAC|\xF0\x9F\x8D\xAD|\xF0\x9F\x8D\xAE|\xF0\x9F\x8D\xAF|\xF0\x9F\x8D\xB0|\xF0\x9F\x8D\xB1|\xF0\x9F\x8D\xB2|\xF0\x9F\x8D\xB3|\xF0\x9F\x8D\xB4|\xF0\x9F\x8D\xB5|\xF0\x9F\x8D\xB6|\xF0\x9F\x8D\xB7|\xF0\x9F\x8D\xB8|\xF0\x9F\x8D\xB9|\xF0\x9F\x8D\xBA|\xF0\x9F\x8D\xBB|\xF0\x9F\x8D\xBC|\xF0\x9F\x8D\xBD|\xF0\x9F\x8D\xBE|\xF0\x9F\x8D\xBF|\xF0\x9F\x8E\x80|\xF0\x9F\x8E\x81|\xF0\x9F\x8E\x82|\xF0\x9F\x8E\x83|\xF0\x9F\x8E\x84|\xF0\x9F\x8E\x85|\xF0\x9F\x8E\x86|\xF0\x9F\x8E\x87|\xF0\x9F\x8E\x88|\xF0\x9F\x8E\x89|\xF0\x9F\x8E\x8A|\xF0\x9F\x8E\x8B|\xF0\x9F\x8E\x8C|\xF0\x9F\x8E\x8D|\xF0\x9F\x8E\x8E|\xF0\x9F\x8E\x8F|\xF0\x9F\x8E\x90|\xF0\x9F\x8E\x91|\xF0\x9F\x8E\x92|\xF0\x9F\x8E\x93|\xF0\x9F\x8E\x94|\xF0\x9F\x8E\x95|\xF0\x9F\x8E\x96|\xF0\x9F\x8E\x97|\xF0\x9F\x8E\x98|\xF0\x9F\x8E\x99|\xF0\x9F\x8E\x9A|\xF0\x9F\x8E\x9B|\xF0\x9F\x8E\x9C|\xF0\x9F\x8E\x9D|\xF0\x9F\x8E\x9E|\xF0\x9F\x8E\x9F|\xF0\x9F\x8E\xA0|\xF0\x9F\x8E\xA1|\xF0\x9F\x8E\xA2|\xF0\x9F\x8E\xA3|\xF0\x9F\x8E\xA4|\xF0\x9F\x8E\xA5|\xF0\x9F\x8E\xA6|\xF0\x9F\x8E\xA7|\xF0\x9F\x8E\xA8|\xF0\x9F\x8E\xA9|\xF0\x9F\x8E\xAA|\xF0\x9F\x8E\xAB|\xF0\x9F\x8E\xAC|\xF0\x9F\x8E\xAD|\xF0\x9F\x8E\xAE|\xF0\x9F\x8E\xAF|\xF0\x9F\x8E\xB0|\xF0\x9F\x8E\xB1|\xF0\x9F\x8E\xB2|\xF0\x9F\x8E\xB3|\xF0\x9F\x8E\xB4|\xF0\x9F\x8E\xB5|\xF0\x9F\x8E\xB6|\xF0\x9F\x8E\xB7|\xF0\x9F\x8E\xB8|\xF0\x9F\x8E\xB9|\xF0\x9F\x8E\xBA|\xF0\x9F\x8E\xBB|\xF0\x9F\x8E\xBC|\xF0\x9F\x8E\xBD|\xF0\x9F\x8E\xBE|\xF0\x9F\x8E\xBF|\xF0\x9F\x8F\x80|\xF0\x9F\x8F\x81|\xF0\x9F\x8F\x82|\xF0\x9F\x8F\x83|\xF0\x9F\x8F\x84|\xF0\x9F\x8F\x85|\xF0\x9F\x8F\x86|\xF0\x9F\x8F\x87|\xF0\x9F\x8F\x88|\xF0\x9F\x8F\x89|\xF0\x9F\x8F\x8A|\xF0\x9F\x8F\x8B|\xF0\x9F\x8F\x8C|\xF0\x9F\x8F\x8D|\xF0\x9F\x8F\x8E|\xF0\x9F\x8F\x8F|\xF0\x9F\x8F\x90|\xF0\x9F\x8F\x91|\xF0\x9F\x8F\x92|\xF0\x9F\x8F\x93|\xF0\x9F\x8F\x94|\xF0\x9F\x8F\x95|\xF0\x9F\x8F\x96|\xF0\x9F\x8F\x97|\xF0\x9F\x8F\x98|\xF0\x9F\x8F\x99|\xF0\x9F\x8F\x9A|\xF0\x9F\x8F\x9B|\xF0\x9F\x8F\x9C|\xF0\x9F\x8F\x9D|\xF0\x9F\x8F\x9E|\xF0\x9F\x8F\x9F|\xF0\x9F\x8F\xA0|\xF0\x9F\x8F\xA1|\xF0\x9F\x8F\xA2|\xF0\x9F\x8F\xA3|\xF0\x9F\x8F\xA4|\xF0\x9F\x8F\xA5|\xF0\x9F\x8F\xA6|\xF0\x9F\x8F\xA7|\xF0\x9F\x8F\xA8|\xF0\x9F\x8F\xA9|\xF0\x9F\x8F\xAA|\xF0\x9F\x8F\xAB|\xF0\x9F\x8F\xAC|\xF0\x9F\x8F\xAD|\xF0\x9F\x8F\xAE|\xF0\x9F\x8F\xAF|\xF0\x9F\x8F\xB0|\xF0\x9F\x8F\xB1|\xF0\x9F\x8F\xB2|\xF0\x9F\x8F\xB3|\xF0\x9F\x8F\xB4|\xF0\x9F\x8F\xB5|\xF0\x9F\x8F\xB6|\xF0\x9F\x8F\xB7|\xF0\x9F\x8F\xB8|\xF0\x9F\x8F\xB9|\xF0\x9F\x8F\xBA|\xF0\x9F\x8F\xBB|\xF0\x9F\x8F\xBC|\xF0\x9F\x8F\xBD|\xF0\x9F\x8F\xBE|\xF0\x9F\x8F\xBF/i;

	$jr_line2 = qr/\xE2\x98\x80|\xE2\x98\x81|\xE2\x98\x82|\xE2\x98\x83|\xE2\x98\x84|\xE2\x98\x85|\xE2\x98\x86|\xE2\x98\x87|\xE2\x98\x88|\xE2\x98\x89|\xE2\x98\x8A|\xE2\x98\x8B|\xE2\x98\x8C|\xE2\x98\x8D|\xE2\x98\x8E|\xE2\x98\x8F|\xE2\x98\x90|\xE2\x98\x91|\xE2\x98\x92|\xE2\x98\x93|\xE2\x98\x94|\xE2\x98\x95|\xE2\x98\x96|\xE2\x98\x97|\xE2\x98\x98|\xE2\x98\x99|\xE2\x98\x9A|\xE2\x98\x9B|\xE2\x98\x9C|\xE2\x98\x9D|\xE2\x98\x9E|\xE2\x98\x9F|\xE2\x98\xA0|\xE2\x98\xA1|\xE2\x98\xA2|\xE2\x98\xA3|\xE2\x98\xA4|\xE2\x98\xA5|\xE2\x98\xA6|\xE2\x98\xA7|\xE2\x98\xA8|\xE2\x98\xA9|\xE2\x98\xAA|\xE2\x98\xAB|\xE2\x98\xAC|\xE2\x98\xAD|\xE2\x98\xAE|\xE2\x98\xAF|\xE2\x98\xB0|\xE2\x98\xB1|\xE2\x98\xB2|\xE2\x98\xB3|\xE2\x98\xB4|\xE2\x98\xB5|\xE2\x98\xB6|\xE2\x98\xB7|\xE2\x98\xB8|\xE2\x98\xB9|\xE2\x98\xBA|\xE2\x98\xBB|\xE2\x98\xBC|\xE2\x98\xBD|\xE2\x98\xBE|\xE2\x98\xBF|\xE2\x99\x80|\xE2\x99\x81|\xE2\x99\x82|\xE2\x99\x83|\xE2\x99\x84|\xE2\x99\x85|\xE2\x99\x86|\xE2\x99\x87|\xE2\x99\x88|\xE2\x99\x89|\xE2\x99\x8A|\xE2\x99\x8B|\xE2\x99\x8C|\xE2\x99\x8D|\xE2\x99\x8E|\xE2\x99\x8F|\xE2\x99\x90|\xE2\x99\x91|\xE2\x99\x92|\xE2\x99\x93|\xE2\x99\x94|\xE2\x99\x95|\xE2\x99\x96|\xE2\x99\x97|\xE2\x99\x98|\xE2\x99\x99|\xE2\x99\x9A|\xE2\x99\x9B|\xE2\x99\x9C|\xE2\x99\x9D|\xE2\x99\x9E|\xE2\x99\x9F|\xE2\x99\xA0|\xE2\x99\xA1|\xE2\x99\xA2|\xE2\x99\xA3|\xE2\x99\xA4|\xE2\x99\xA5|\xE2\x99\xA6|\xE2\x99\xA7|\xE2\x99\xA8|\xE2\x99\xA9|\xE2\x99\xAA|\xE2\x99\xAB|\xE2\x99\xAC|\xE2\x99\xAD|\xE2\x99\xAE|\xE2\x99\xAF|\xE2\x99\xB0|\xE2\x99\xB1|\xE2\x99\xB2|\xE2\x99\xB3|\xE2\x99\xB4|\xE2\x99\xB5|\xE2\x99\xB6|\xE2\x99\xB7|\xE2\x99\xB8|\xE2\x99\xB9|\xE2\x99\xBA|\xE2\x99\xBB|\xE2\x99\xBC|\xE2\x99\xBD|\xE2\x99\xBE|\xE2\x99\xBF|\xE2\x9A\x80|\xE2\x9A\x81|\xE2\x9A\x82|\xE2\x9A\x83|\xE2\x9A\x84|\xE2\x9A\x85|\xE2\x9A\x86|\xE2\x9A\x87|\xE2\x9A\x88|\xE2\x9A\x89|\xE2\x9A\x8A|\xE2\x9A\x8B|\xE2\x9A\x8C|\xE2\x9A\x8D|\xE2\x9A\x8E|\xE2\x9A\x8F|\xE2\x9A\x90|\xE2\x9A\x91|\xE2\x9A\x92|\xE2\x9A\x93|\xE2\x9A\x94|\xE2\x9A\x95|\xE2\x9A\x96|\xE2\x9A\x97|\xE2\x9A\x98|\xE2\x9A\x99|\xE2\x9A\x9A|\xE2\x9A\x9B|\xE2\x9A\x9C|\xE2\x9A\x9D|\xE2\x9A\x9E|\xE2\x9A\x9F|\xE2\x9A\xA0|\xE2\x9A\xA1|\xE2\x9A\xA2|\xE2\x9A\xA3|\xE2\x9A\xA4|\xE2\x9A\xA5|\xE2\x9A\xA6|\xE2\x9A\xA7|\xE2\x9A\xA8|\xE2\x9A\xA9|\xE2\x9A\xAA|\xE2\x9A\xAB|\xE2\x9A\xAC|\xE2\x9A\xAD|\xE2\x9A\xAE|\xE2\x9A\xAF|\xE2\x9A\xB0|\xE2\x9A\xB1|\xE2\x9A\xB2|\xE2\x9A\xB3|\xE2\x9A\xB4|\xE2\x9A\xB5|\xE2\x9A\xB6|\xE2\x9A\xB7|\xE2\x9A\xB8|\xE2\x9A\xB9|\xE2\x9A\xBA|\xE2\x9A\xBB|\xE2\x9A\xBC|\xE2\x9A\xBD|\xE2\x9A\xBE|\xE2\x9A\xBF|\xE2\x9B\x80|\xE2\x9B\x81|\xE2\x9B\x82|\xE2\x9B\x83|\xE2\x9B\x84|\xE2\x9B\x85|\xE2\x9B\x86|\xE2\x9B\x87|\xE2\x9B\x88|\xE2\x9B\x89|\xE2\x9B\x8A|\xE2\x9B\x8B|\xE2\x9B\x8C|\xE2\x9B\x8D|\xE2\x9B\x8E|\xE2\x9B\x8F|\xE2\x9B\x90|\xE2\x9B\x91|\xE2\x9B\x92|\xE2\x9B\x93|\xE2\x9B\x94|\xE2\x9B\x95|\xE2\x9B\x96|\xE2\x9B\x97|\xE2\x9B\x98|\xE2\x9B\x99|\xE2\x9B\x9A|\xE2\x9B\x9B|\xE2\x9B\x9C|\xE2\x9B\x9D|\xE2\x9B\x9E|\xE2\x9B\x9F|\xE2\x9B\xA0|\xE2\x9B\xA1|\xE2\x9B\xA2|\xE2\x9B\xA3|\xE2\x9B\xA4|\xE2\x9B\xA5|\xE2\x9B\xA6|\xE2\x9B\xA7|\xE2\x9B\xA8|\xE2\x9B\xA9|\xE2\x9B\xAA|\xE2\x9B\xAB|\xE2\x9B\xAC|\xE2\x9B\xAD|\xE2\x9B\xAE|\xE2\x9B\xAF|\xE2\x9B\xB0|\xE2\x9B\xB1|\xE2\x9B\xB2|\xE2\x9B\xB3|\xE2\x9B\xB4|\xE2\x9B\xB5|\xE2\x9B\xB6|\xE2\x9B\xB7|\xE2\x9B\xB8|\xE2\x9B\xB9|\xE2\x9B\xBA|\xE2\x9B\xBB|\xE2\x9B\xBC|\xE2\x9B\xBD|\xE2\x9B\xBE|\xE2\x9B\xBF/i;

	$jr_line3 = qr/\xF0\x9F\x90\x80|\xF0\x9F\x90\x81|\xF0\x9F\x90\x82|\xF0\x9F\x90\x83|\xF0\x9F\x90\x84|\xF0\x9F\x90\x85|\xF0\x9F\x90\x86|\xF0\x9F\x90\x87|\xF0\x9F\x90\x88|\xF0\x9F\x90\x89|\xF0\x9F\x90\x8A|\xF0\x9F\x90\x8B|\xF0\x9F\x90\x8C|\xF0\x9F\x90\x8D|\xF0\x9F\x90\x8E|\xF0\x9F\x90\x8F|\xF0\x9F\x90\x90|\xF0\x9F\x90\x91|\xF0\x9F\x90\x92|\xF0\x9F\x90\x93|\xF0\x9F\x90\x94|\xF0\x9F\x90\x95|\xF0\x9F\x90\x96|\xF0\x9F\x90\x97|\xF0\x9F\x90\x98|\xF0\x9F\x90\x99|\xF0\x9F\x90\x9A|\xF0\x9F\x90\x9B|\xF0\x9F\x90\x9C|\xF0\x9F\x90\x9D|\xF0\x9F\x90\x9E|\xF0\x9F\x90\x9F|\xF0\x9F\x90\xA0|\xF0\x9F\x90\xA1|\xF0\x9F\x90\xA2|\xF0\x9F\x90\xA3|\xF0\x9F\x90\xA4|\xF0\x9F\x90\xA5|\xF0\x9F\x90\xA6|\xF0\x9F\x90\xA7|\xF0\x9F\x90\xA8|\xF0\x9F\x90\xA9|\xF0\x9F\x90\xAA|\xF0\x9F\x90\xAB|\xF0\x9F\x90\xAC|\xF0\x9F\x90\xAD|\xF0\x9F\x90\xAE|\xF0\x9F\x90\xAF|\xF0\x9F\x90\xB0|\xF0\x9F\x90\xB1|\xF0\x9F\x90\xB2|\xF0\x9F\x90\xB3|\xF0\x9F\x90\xB4|\xF0\x9F\x90\xB5|\xF0\x9F\x90\xB6|\xF0\x9F\x90\xB7|\xF0\x9F\x90\xB8|\xF0\x9F\x90\xB9|\xF0\x9F\x90\xBA|\xF0\x9F\x90\xBB|\xF0\x9F\x90\xBC|\xF0\x9F\x90\xBD|\xF0\x9F\x90\xBE|\xF0\x9F\x90\xBF|\xF0\x9F\x91\x80|\xF0\x9F\x91\x81|\xF0\x9F\x91\x82|\xF0\x9F\x91\x83|\xF0\x9F\x91\x84|\xF0\x9F\x91\x85|\xF0\x9F\x91\x86|\xF0\x9F\x91\x87|\xF0\x9F\x91\x88|\xF0\x9F\x91\x89|\xF0\x9F\x91\x8A|\xF0\x9F\x91\x8B|\xF0\x9F\x91\x8C|\xF0\x9F\x91\x8D|\xF0\x9F\x91\x8E|\xF0\x9F\x91\x8F|\xF0\x9F\x91\x90|\xF0\x9F\x91\x91|\xF0\x9F\x91\x92|\xF0\x9F\x91\x93|\xF0\x9F\x91\x94|\xF0\x9F\x91\x95|\xF0\x9F\x91\x96|\xF0\x9F\x91\x97|\xF0\x9F\x91\x98|\xF0\x9F\x91\x99|\xF0\x9F\x91\x9A|\xF0\x9F\x91\x9B|\xF0\x9F\x91\x9C|\xF0\x9F\x91\x9D|\xF0\x9F\x91\x9E|\xF0\x9F\x91\x9F|\xF0\x9F\x91\xA0|\xF0\x9F\x91\xA1|\xF0\x9F\x91\xA2|\xF0\x9F\x91\xA3|\xF0\x9F\x91\xA4|\xF0\x9F\x91\xA5|\xF0\x9F\x91\xA6|\xF0\x9F\x91\xA7|\xF0\x9F\x91\xA8|\xF0\x9F\x91\xA9|\xF0\x9F\x91\xAA|\xF0\x9F\x91\xAB|\xF0\x9F\x91\xAC|\xF0\x9F\x91\xAD|\xF0\x9F\x91\xAE|\xF0\x9F\x91\xAF|\xF0\x9F\x91\xB0|\xF0\x9F\x91\xB1|\xF0\x9F\x91\xB2|\xF0\x9F\x91\xB3|\xF0\x9F\x91\xB4|\xF0\x9F\x91\xB5|\xF0\x9F\x91\xB6|\xF0\x9F\x91\xB7|\xF0\x9F\x91\xB8|\xF0\x9F\x91\xB9|\xF0\x9F\x91\xBA|\xF0\x9F\x91\xBB|\xF0\x9F\x91\xBC|\xF0\x9F\x91\xBD|\xF0\x9F\x91\xBE|\xF0\x9F\x91\xBF|\xF0\x9F\x9B\xA0|\xF0\x9F\x9B\xA1|\xF0\x9F\x9B\xA2|\xF0\x9F\x9B\xA3|\xF0\x9F\x9B\xA4|\xF0\x9F\x9B\xA5|\xF0\x9F\x9B\xA6|\xF0\x9F\x9B\xA7|\xF0\x9F\x9B\xA8|\xF0\x9F\x9B\xA9|\xF0\x9F\x9B\xAA|\xF0\x9F\x9B\xAB|\xF0\x9F\x9B\xAC|\xF0\x9F\x9B\xAD|\xF0\x9F\x9B\xAE|\xF0\x9F\x9B\xAF|\xF0\x9F\x9B\xB0|\xF0\x9F\x9B\xB1|\xF0\x9F\x9B\xB2|\xF0\x9F\x9B\xB3|\xF0\x9F\x9B\xB4|\xF0\x9F\x9B\xB5|\xF0\x9F\x9B\xB6|\xF0\x9F\x9B\xB7|\xF0\x9F\x9B\xB8|\xF0\x9F\x9B\xB9|\xF0\x9F\x9B\xBA|\xF0\x9F\x9B\xBB|\xF0\x9F\x9B\xBC|\xF0\x9F\x95\x80|\xF0\x9F\x95\x81|\xF0\x9F\x95\x82|\xF0\x9F\x95\x83|\xF0\x9F\x95\x84|\xF0\x9F\x95\x85|\xF0\x9F\x95\x86|\xF0\x9F\x95\x87|\xF0\x9F\x95\x88|\xF0\x9F\x95\x89|\xF0\x9F\x95\x8A|\xF0\x9F\x95\x8B|\xF0\x9F\x95\x8C|\xF0\x9F\x95\x8D|\xF0\x9F\x95\x8E|\xF0\x9F\x95\x8F|\xF0\x9F\x95\x90|\xF0\x9F\x95\x91|\xF0\x9F\x95\x92|\xF0\x9F\x95\x93|\xF0\x9F\x95\x94|\xF0\x9F\x95\x95|\xF0\x9F\x95\x96|\xF0\x9F\x95\x97|\xF0\x9F\x95\x98|\xF0\x9F\x95\x99|\xF0\x9F\x95\x9A|\xF0\x9F\x95\x9B|\xF0\x9F\x95\x9C|\xF0\x9F\x95\x9D|\xF0\x9F\x95\x9E|\xF0\x9F\x95\x9F|\xF0\x9F\x95\xA0|\xF0\x9F\x95\xA1|\xF0\x9F\x95\xA2|\xF0\x9F\x95\xA3|\xF0\x9F\x95\xA4|\xF0\x9F\x95\xA5|\xF0\x9F\x95\xA6|\xF0\x9F\x95\xA7|\xF0\x9F\x95\xA8|\xF0\x9F\x95\xA9|\xF0\x9F\x95\xAA|\xF0\x9F\x95\xAB|\xF0\x9F\x95\xAC|\xF0\x9F\x95\xAD|\xF0\x9F\x95\xAE|\xF0\x9F\x95\xAF|\xF0\x9F\x95\xB0|\xF0\x9F\x95\xB1|\xF0\x9F\x95\xB2|\xF0\x9F\x95\xB3|\xF0\x9F\x95\xB4|\xF0\x9F\x95\xB5|\xF0\x9F\x95\xB6|\xF0\x9F\x95\xB7|\xF0\x9F\x95\xB8|\xF0\x9F\x95\xB9|\xF0\x9F\x95\xBA|\xF0\x9F\x95\xBB|\xF0\x9F\x95\xBC|\xF0\x9F\x95\xBD|\xF0\x9F\x95\xBE|\xF0\x9F\x95\xBF|\xF0\x9F\x96\x80|\xF0\x9F\x96\x81|\xF0\x9F\x96\x82|\xF0\x9F\x96\x83|\xF0\x9F\x96\x84|\xF0\x9F\x96\x85|\xF0\x9F\x96\x86|\xF0\x9F\x96\x87|\xF0\x9F\x96\x88|\xF0\x9F\x96\x89|\xF0\x9F\x96\x8A|\xF0\x9F\x96\x8B|\xF0\x9F\x96\x8C|\xF0\x9F\x96\x8D|\xF0\x9F\x96\x8E|\xF0\x9F\x96\x8F|\xF0\x9F\x96\x90|\xF0\x9F\x96\x91|\xF0\x9F\x96\x92|\xF0\x9F\x96\x93|\xF0\x9F\x96\x94|\xF0\x9F\x96\x95|\xF0\x9F\x96\x96|\xF0\x9F\x96\x97|\xF0\x9F\x96\x98|\xF0\x9F\x96\x99|\xF0\x9F\x96\x9A|\xF0\x9F\x96\x9B|\xF0\x9F\x96\x9C|\xF0\x9F\x96\x9D|\xF0\x9F\x96\x9E|\xF0\x9F\x96\x9F|\xF0\x9F\x96\xA0|\xF0\x9F\x96\xA1|\xF0\x9F\x96\xA2|\xF0\x9F\x96\xA3|\xF0\x9F\x96\xA4|\xF0\x9F\x96\xA5|\xF0\x9F\x96\xA6|\xF0\x9F\x96\xA7|\xF0\x9F\x96\xA8|\xF0\x9F\x96\xA9|\xF0\x9F\x96\xAA|\xF0\x9F\x96\xAB|\xF0\x9F\x96\xAC|\xF0\x9F\x96\xAD|\xF0\x9F\x96\xAE|\xF0\x9F\x96\xAF|\xF0\x9F\x96\xB0|\xF0\x9F\x96\xB1|\xF0\x9F\x96\xB2|\xF0\x9F\x96\xB3|\xF0\x9F\x96\xB4|\xF0\x9F\x96\xB5|\xF0\x9F\x96\xB6|\xF0\x9F\x96\xB7|\xF0\x9F\x96\xB8|\xF0\x9F\x96\xB9|\xF0\x9F\x96\xBA|\xF0\x9F\x96\xBB|\xF0\x9F\x96\xBC|\xF0\x9F\x96\xBD|\xF0\x9F\x96\xBE|\xF0\x9F\x96\xBF|\xF0\x9F\x97\x80|\xF0\x9F\x97\x81|\xF0\x9F\x97\x82|\xF0\x9F\x97\x83|\xF0\x9F\x97\x84|\xF0\x9F\x97\x85|\xF0\x9F\x97\x86|\xF0\x9F\x97\x87|\xF0\x9F\x97\x88|\xF0\x9F\x97\x89|\xF0\x9F\x97\x8A|\xF0\x9F\x97\x8B|\xF0\x9F\x97\x8C|\xF0\x9F\x97\x8D|\xF0\x9F\x97\x8E|\xF0\x9F\x97\x8F|\xF0\x9F\x97\x90|\xF0\x9F\x97\x91|\xF0\x9F\x97\x92|\xF0\x9F\x97\x93|\xF0\x9F\x97\x94|\xF0\x9F\x97\x95|\xF0\x9F\x97\x96|\xF0\x9F\x97\x97|\xF0\x9F\x97\x98|\xF0\x9F\x97\x99|\xF0\x9F\x97\x9A|\xF0\x9F\x97\x9B|\xF0\x9F\x97\x9C|\xF0\x9F\x97\x9D|\xF0\x9F\x97\x9E|\xF0\x9F\x97\x9F|\xF0\x9F\x97\xA0|\xF0\x9F\x97\xA1|\xF0\x9F\x97\xA2|\xF0\x9F\x97\xA3|\xF0\x9F\x97\xA4|\xF0\x9F\x97\xA5|\xF0\x9F\x97\xA6|\xF0\x9F\x97\xA7|\xF0\x9F\x97\xA8|\xF0\x9F\x97\xA9|\xF0\x9F\x97\xAA|\xF0\x9F\x97\xAB|\xF0\x9F\x97\xAC|\xF0\x9F\x97\xAD|\xF0\x9F\x97\xAE|\xF0\x9F\x97\xAF|\xF0\x9F\x97\xB0|\xF0\x9F\x97\xB1|\xF0\x9F\x97\xB2|\xF0\x9F\x97\xB3|\xF0\x9F\x97\xB4|\xF0\x9F\x97\xB5|\xF0\x9F\x97\xB6|\xF0\x9F\x97\xB7|\xF0\x9F\x97\xB8|\xF0\x9F\x97\xB9|\xF0\x9F\x97\xBA|\xF0\x9F\x97\xBB|\xF0\x9F\x97\xBC|\xF0\x9F\x97\xBD|\xF0\x9F\x97\xBE|\xF0\x9F\x97\xBF/i;
	
	$jr_line4 = qr/\xE2\x8F\x8E|\xE2\x8F\x8F|\xE2\x8F\xA9|\xE2\x8F\xAA|\xE2\x8F\xAB|\xE2\x8F\xAC|\xE2\x8F\xAD|\xE2\x8F\xAE|\xE2\x8F\xAF|\xE2\x8F\xB0|\xE2\x8F\xB1|\xE2\x8F\xB2|\xE2\x8F\xB3|\xE2\x8F\xB4|\xE2\x8F\xB5|\xE2\x8F\xB6|\xE2\x8F\xB7|\xE2\x8F\xB8|\xE2\x8F\xB9|\xE2\x8F\xBA|\xEF\xB8\x80|\xEF\xB8\x81|\xEF\xB8\x82|\xEF\xB8\x83|\xEF\xB8\x84|\xEF\xB8\x85|\xEF\xB8\x86|\xEF\xB8\x87|\xEF\xB8\x88|\xEF\xB8\x89|\xEF\xB8\x8A|\xEF\xB8\x8B|\xEF\xB8\x8C|\xEF\xB8\x8D|\xEF\xB8\x8E|\xEF\xB8\x8F|\xEF\xB8\x90|\xEF\xB8\x91|\xEF\xB8\x92|\xEF\xB8\x93|\xEF\xB8\x94|\xEF\xB8\x95|\xEF\xB8\x96|\xEF\xB8\x97|\xEF\xB8\x98|\xEF\xB8\x99|\xEF\xB8\x9A|\xEF\xB8\x9B|\xEF\xB8\x9C|\xEF\xB8\x9D|\xEF\xB8\x9E|\xEF\xB8\x9F|\xEF\xB8\xA0|\xEF\xB8\xA1|\xEF\xB8\xA2|\xEF\xB8\xA3|\xEF\xB8\xA4|\xEF\xB8\xA5|\xEF\xB8\xA6|\xEF\xB8\xA7|\xEF\xB8\xA8|\xEF\xB8\xA9|\xEF\xB8\xAA|\xEF\xB8\xAB|\xEF\xB8\xAC|\xEF\xB8\xAD|\xEF\xB8\xAE|\xEF\xB8\xAF|\xEF\xB8\xB0|\xEF\xB8\xB1|\xEF\xB8\xB2|\xEF\xB8\xB3|\xEF\xB8\xB4|\xEF\xB8\xB5|\xEF\xB8\xB6|\xEF\xB8\xB7|\xEF\xB8\xB8|\xEF\xB8\xB9|\xEF\xB8\xBA|\xEF\xB8\xBB|\xEF\xB8\xBC|\xEF\xB8\xBD|\xEF\xB8\xBE|\xEF\xB8\xBF|\xEF\xB9\x80|\xEF\xB9\x81|\xEF\xB9\x82|\xEF\xB9\x83|\xEF\xB9\x84|\xEF\xB9\x85|\xEF\xB9\x86|\xEF\xB9\x87|\xEF\xB9\x88|\xEF\xB9\x89|\xEF\xB9\x8A|\xEF\xB9\x8B|\xEF\xB9\x8C|\xEF\xB9\x8D|\xEF\xB9\x8E|\xEF\xB9\x8F|\xEF\xB9\x90|\xEF\xB9\x91|\xEF\xB9\x92|\xEF\xB9\x93|\xEF\xB9\x94|\xEF\xB9\x95|\xEF\xB9\x96|\xEF\xB9\x97|\xEF\xB9\x98|\xEF\xB9\x99|\xEF\xB9\x9A|\xEF\xB9\x9B|\xEF\xB9\x9C|\xEF\xB9\x9D|\xEF\xB9\x9E|\xEF\xB9\x9F|\xEF\xB9\xA0|\xEF\xB9\xA1|\xEF\xB9\xA2|\xEF\xB9\xA3|\xEF\xB9\xA4|\xEF\xB9\xA5|\xEF\xB9\xA6|\xEF\xB9\xA7|\xEF\xB9\xA8|\xEF\xB9\xA9|\xEF\xB9\xAA|\xEF\xB9\xAB|\xEF\xB9\xAC|\xEF\xB9\xAD|\xEF\xB9\xAE|\xEF\xB9\xAF|\xEF\xB9\xB0|\xEF\xB9\xB1|\xEF\xB9\xB2|\xEF\xB9\xB3|\xEF\xB9\xB4|\xEF\xB9\xB5|\xEF\xB9\xB6|\xEF\xB9\xB7|\xEF\xB9\xB8|\xEF\xB9\xB9|\xEF\xB9\xBA|\xEF\xB9\xBB|\xEF\xB9\xBC|\xEF\xB9\xBD|\xEF\xB9\xBE|\xEF\xB9\xBF|\xEF\xBA\x80|\xEF\xBA\x81|\xEF\xBA\x82|\xEF\xBA\x83|\xEF\xBA\x84|\xEF\xBA\x85|\xEF\xBA\x86|\xEF\xBA\x87|\xEF\xBA\x88|\xEF\xBA\x89|\xEF\xBA\x8A|\xEF\xBA\x8B|\xEF\xBA\x8C|\xEF\xBA\x8D|\xEF\xBA\x8E|\xEF\xBA\x8F|\xEF\xBA\x90|\xEF\xBA\x91|\xEF\xBA\x92|\xEF\xBA\x93|\xEF\xBA\x94|\xEF\xBA\x95|\xEF\xBA\x96|\xEF\xBA\x97|\xEF\xBA\x98|\xEF\xBA\x99|\xEF\xBA\x9A|\xEF\xBA\x9B|\xEF\xBA\x9C|\xEF\xBA\x9D|\xEF\xBA\x9E|\xEF\xBA\x9F|\xEF\xBA\xA0|\xEF\xBA\xA1|\xEF\xBA\xA2|\xEF\xBA\xA3|\xEF\xBA\xA4|\xEF\xBA\xA5|\xEF\xBA\xA6|\xEF\xBA\xA7|\xEF\xBA\xA8|\xEF\xBA\xA9|\xEF\xBA\xAA|\xEF\xBA\xAB|\xEF\xBA\xAC|\xEF\xBA\xAD|\xEF\xBA\xAE|\xEF\xBA\xAF|\xEF\xBA\xB0|\xEF\xBA\xB1|\xEF\xBA\xB2|\xEF\xBA\xB3|\xEF\xBA\xB4|\xEF\xBA\xB5|\xEF\xBA\xB6|\xEF\xBA\xB7|\xEF\xBA\xB8|\xEF\xBA\xB9|\xEF\xBA\xBA|\xEF\xBA\xBB|\xEF\xBA\xBC|\xEF\xBA\xBD|\xEF\xBA\xBE|\xEF\xBA\xBF|\xEF\xBB\x80|\xEF\xBB\x81|\xEF\xBB\x82|\xEF\xBB\x83|\xEF\xBB\x84|\xEF\xBB\x85|\xEF\xBB\x86|\xEF\xBB\x87|\xEF\xBB\x88|\xEF\xBB\x89|\xEF\xBB\x8A|\xEF\xBB\x8B|\xEF\xBB\x8C|\xEF\xBB\x8D|\xEF\xBB\x8E|\xEF\xBB\x8F|\xEF\xBB\x90|\xEF\xBB\x91|\xEF\xBB\x92|\xEF\xBB\x93|\xEF\xBB\x94|\xEF\xBB\x95|\xEF\xBB\x96|\xEF\xBB\x97|\xEF\xBB\x98|\xEF\xBB\x99|\xEF\xBB\x9A|\xEF\xBB\x9B|\xEF\xBB\x9C|\xEF\xBB\x9D|\xEF\xBB\x9E|\xEF\xBB\x9F|\xEF\xBB\xA0|\xEF\xBB\xA1|\xEF\xBB\xA2|\xEF\xBB\xA3|\xEF\xBB\xA4|\xEF\xBB\xA5|\xEF\xBB\xA6|\xEF\xBB\xA7|\xEF\xBB\xA8|\xEF\xBB\xA9|\xEF\xBB\xAA|\xEF\xBB\xAB|\xEF\xBB\xAC|\xEF\xBB\xAD|\xEF\xBB\xAE|\xEF\xBB\xAF|\xEF\xBB\xB0|\xEF\xBB\xB1|\xEF\xBB\xB2|\xEF\xBB\xB3|\xEF\xBB\xB4|\xEF\xBB\xB5|\xEF\xBB\xB6|\xEF\xBB\xB7|\xEF\xBB\xB8|\xEF\xBB\xB9|\xEF\xBB\xBA|\xEF\xBB\xBB|\xEF\xBB\xBC|\xEF\xBB\xBD|\xEF\xBB\xBE|\xEF\xBB\xBF/i;
	
	$jr_line5 = qr/\xF0\x9F\x92\x80|\xF0\x9F\x92\x81|\xF0\x9F\x92\x82|\xF0\x9F\x92\x83|\xF0\x9F\x92\x84|\xF0\x9F\x92\x85|\xF0\x9F\x92\x86|\xF0\x9F\x92\x87|\xF0\x9F\x92\x88|\xF0\x9F\x92\x89|\xF0\x9F\x92\x8A|\xF0\x9F\x92\x8B|\xF0\x9F\x92\x8C|\xF0\x9F\x92\x8D|\xF0\x9F\x92\x8E|\xF0\x9F\x92\x8F|\xF0\x9F\x92\x90|\xF0\x9F\x92\x91|\xF0\x9F\x92\x92|\xF0\x9F\x92\x93|\xF0\x9F\x92\x94|\xF0\x9F\x92\x95|\xF0\x9F\x92\x96|\xF0\x9F\x92\x97|\xF0\x9F\x92\x98|\xF0\x9F\x92\x99|\xF0\x9F\x92\x9A|\xF0\x9F\x92\x9B|\xF0\x9F\x92\x9C|\xF0\x9F\x92\x9D|\xF0\x9F\x92\x9E|\xF0\x9F\x92\x9F|\xF0\x9F\x92\xA0|\xF0\x9F\x92\xA1|\xF0\x9F\x92\xA2|\xF0\x9F\x92\xA3|\xF0\x9F\x92\xA4|\xF0\x9F\x92\xA5|\xF0\x9F\x92\xA6|\xF0\x9F\x92\xA7|\xF0\x9F\x92\xA8|\xF0\x9F\x92\xA9|\xF0\x9F\x92\xAA|\xF0\x9F\x92\xAB|\xF0\x9F\x92\xAC|\xF0\x9F\x92\xAD|\xF0\x9F\x92\xAE|\xF0\x9F\x92\xAF|\xF0\x9F\x92\xB0|\xF0\x9F\x92\xB1|\xF0\x9F\x92\xB2|\xF0\x9F\x92\xB3|\xF0\x9F\x92\xB4|\xF0\x9F\x92\xB5|\xF0\x9F\x92\xB6|\xF0\x9F\x92\xB7|\xF0\x9F\x92\xB8|\xF0\x9F\x92\xB9|\xF0\x9F\x92\xBA|\xF0\x9F\x92\xBB|\xF0\x9F\x92\xBC|\xF0\x9F\x92\xBD|\xF0\x9F\x92\xBE|\xF0\x9F\x92\xBF|\xF0\x9F\x93\x80|\xF0\x9F\x93\x81|\xF0\x9F\x93\x82|\xF0\x9F\x93\x83|\xF0\x9F\x93\x84|\xF0\x9F\x93\x85|\xF0\x9F\x93\x86|\xF0\x9F\x93\x87|\xF0\x9F\x93\x88|\xF0\x9F\x93\x89|\xF0\x9F\x93\x8A|\xF0\x9F\x93\x8B|\xF0\x9F\x93\x8C|\xF0\x9F\x93\x8D|\xF0\x9F\x93\x8E|\xF0\x9F\x93\x8F|\xF0\x9F\x93\x90|\xF0\x9F\x93\x91|\xF0\x9F\x93\x92|\xF0\x9F\x93\x93|\xF0\x9F\x93\x94|\xF0\x9F\x93\x95|\xF0\x9F\x93\x96|\xF0\x9F\x93\x97|\xF0\x9F\x93\x98|\xF0\x9F\x93\x99|\xF0\x9F\x93\x9A|\xF0\x9F\x93\x9B|\xF0\x9F\x93\x9C|\xF0\x9F\x93\x9D|\xF0\x9F\x93\x9E|\xF0\x9F\x93\x9F|\xF0\x9F\x93\xA0|\xF0\x9F\x93\xA1|\xF0\x9F\x93\xA2|\xF0\x9F\x93\xA3|\xF0\x9F\x93\xA4|\xF0\x9F\x93\xA5|\xF0\x9F\x93\xA6|\xF0\x9F\x93\xA7|\xF0\x9F\x93\xA8|\xF0\x9F\x93\xA9|\xF0\x9F\x93\xAA|\xF0\x9F\x93\xAB|\xF0\x9F\x93\xAC|\xF0\x9F\x93\xAD|\xF0\x9F\x93\xAE|\xF0\x9F\x93\xAF|\xF0\x9F\x93\xB0|\xF0\x9F\x93\xB1|\xF0\x9F\x93\xB2|\xF0\x9F\x93\xB3|\xF0\x9F\x93\xB4|\xF0\x9F\x93\xB5|\xF0\x9F\x93\xB6|\xF0\x9F\x93\xB7|\xF0\x9F\x93\xB8|\xF0\x9F\x93\xB9|\xF0\x9F\x93\xBA|\xF0\x9F\x93\xBB|\xF0\x9F\x93\xBC|\xF0\x9F\x93\xBD|\xF0\x9F\x93\xBE|\xF0\x9F\x93\xBF|\xF0\x9F\x94\x80|\xF0\x9F\x94\x81|\xF0\x9F\x94\x82LED|ONE|OVERLAY|\xF0\x9F\x94\x83|\xF0\x9F\x94\x84|\xF0\x9F\x94\x85|\xF0\x9F\x94\x86|\xF0\x9F\x94\x87|\xF0\x9F\x94\x88|\xF0\x9F\x94\x89|\xF0\x9F\x94\x8A|\xF0\x9F\x94\x8B|\xF0\x9F\x94\x8C|\xF0\x9F\x94\x8D|\xF0\x9F\x94\x8E|\xF0\x9F\x94\x8F|\xF0\x9F\x94\x90|\xF0\x9F\x94\x91|\xF0\x9F\x94\x92|\xF0\x9F\x94\x93|\xF0\x9F\x94\x94|\xF0\x9F\x94\x95|\xF0\x9F\x94\x96|\xF0\x9F\x94\x97|\xF0\x9F\x94\x98|\xF0\x9F\x94\x99|\xF0\x9F\x94\x9A|\xF0\x9F\x94\x9B|\xF0\x9F\x94\x9C|\xF0\x9F\x94\x9D|\xF0\x9F\x94\x9E|\xF0\x9F\x94\x9F|\xF0\x9F\x94\xA0|\xF0\x9F\x94\xA1|\xF0\x9F\x94\xA2|\xF0\x9F\x94\xA3|\xF0\x9F\x94\xA4|\xF0\x9F\x94\xA5|\xF0\x9F\x94\xA6|\xF0\x9F\x94\xA7|\xF0\x9F\x94\xA8|\xF0\x9F\x94\xA9|\xF0\x9F\x94\xAA|\xF0\x9F\x94\xAB|\xF0\x9F\x94\xAC|\xF0\x9F\x94\xAD|\xF0\x9F\x94\xAE|\xF0\x9F\x94\xAF|\xF0\x9F\x94\xB0|\xF0\x9F\x94\xB1|\xF0\x9F\x94\xB2|\xF0\x9F\x94\xB3|\xF0\x9F\x94\xB4|\xF0\x9F\x94\xB5|\xF0\x9F\x94\xB6|\xF0\x9F\x94\xB7|\xF0\x9F\x94\xB8|\xF0\x9F\x94\xB9|\xF0\x9F\x94\xBA|\xF0\x9F\x94\xBB|\xF0\x9F\x94\xBC|\xF0\x9F\x94\xBD|\xF0\x9F\x94\xBE|\xF0\x9F\x94\xBF|\xF0\x9F\x95\x80|\xF0\x9F\x95\x81|\xF0\x9F\x95\x82|\xF0\x9F\x95\x83|\xF0\x9F\x95\x84|\xF0\x9F\x95\x85|\xF0\x9F\x95\x86|\xF0\x9F\x95\x87|\xF0\x9F\x95\x88|\xF0\x9F\x95\x89|\xF0\x9F\x95\x8A|\xF0\x9F\x95\x8B|\xF0\x9F\x95\x8C|\xF0\x9F\x95\x8D|\xF0\x9F\x95\x8E|\xF0\x9F\x95\x8F|\xF0\x9F\x95\x90|\xF0\x9F\x95\x91|\xF0\x9F\x95\x92|\xF0\x9F\x95\x93|\xF0\x9F\x95\x94|\xF0\x9F\x95\x95|\xF0\x9F\x95\x96|\xF0\x9F\x95\x97|\xF0\x9F\x95\x98|\xF0\x9F\x95\x99|\xF0\x9F\x95\x9A|\xF0\x9F\x95\x9B|\xF0\x9F\x95\x9C|\xF0\x9F\x95\x9D|\xF0\x9F\x95\x9E|\xF0\x9F\x95\x9F|\xF0\x9F\x95\xA0|\xF0\x9F\x95\xA1|\xF0\x9F\x95\xA2|\xF0\x9F\x95\xA3|\xF0\x9F\x95\xA4|\xF0\x9F\x95\xA5|\xF0\x9F\x95\xA6|\xF0\x9F\x95\xA7|\xF0\x9F\x95\xA8|\xF0\x9F\x95\xA9|\xF0\x9F\x95\xAA|\xF0\x9F\x95\xAB|\xF0\x9F\x95\xAC|\xF0\x9F\x95\xAD|\xF0\x9F\x95\xAE|\xF0\x9F\x95\xAF|\xF0\x9F\x95\xB0|\xF0\x9F\x95\xB1|\xF0\x9F\x95\xB2|\xF0\x9F\x95\xB3|\xF0\x9F\x95\xB4|\xF0\x9F\x95\xB5|\xF0\x9F\x95\xB6|\xF0\x9F\x95\xB7|\xF0\x9F\x95\xB8|\xF0\x9F\x95\xB9|\xF0\x9F\x95\xBA|\xF0\x9F\x95\xBB|\xF0\x9F\x95\xBC|\xF0\x9F\x95\xBD|\xF0\x9F\x95\xBE|\xF0\x9F\x95\xBF/i;

return();
}

sub admin_match {
	$myadmin = qr/Important\salert\son\syour\saccount|Password\sExpire\sFor\s[a-z0-9.]+\@[a-z0-9.-]+|IT\sWarning\sfor\s[a-z0-9.]+\@[a-z0-9.-]+\sMailBox\sAccount|Warning\:\sEmail\supgrade\srequired\sfor\syour\smailbox\s\-|You\shave\s\[?\d+\]?\snew\spending\smails\son|You\shave\s\[?\d+\]?\sundelivered\smails\son|Retrieve\sPending\sMessages\sfor\s.*\@.*|New\sSecure\-mail\s\([0-9]{3,7}\)|New\smessage\s\([0-9]{1,3}\)|:\s:\sMail\sServer\sErrors|Email\sAdministrator\.|Several\semail\sMessages\sHindered\sfrom\sdelivery|ACCOUNT\sSHUTDOWN\sNOTIFICATION|There\sare\snew\smessages\sin\syour\sEmail\sQuarantine|Mail\sSystem\s\-\sNotification|Please\sverify\syour\semail\saccount\s[a-z0-9.]+\@[a-z0-9.-]+|You\shave\s\{\d\}\smessages\sundelivered\sfor\s[a-z0-9.]+\@[a-z0-9.-]+|mailbox:\sNew\sfound\smessages\sin\squarantine:|Please\sverify\syour\semail\saccount\s[a-z0-9.]+\@[a-z0-9.-]+|You\shave\s\{\d\}\smessages\sundelivered\sfor\s[a-z0-9.]+\@[a-z0-9.-]+|Urgent\sSecurity\sUpdate\sDocuments|Final\sWarning\,\sYour\sEmail|Email\sSuspension\s\(last\swarning\!\!\)|Attention:\sEmail\sOwner|Notice\s:\sYour\sEmail\sIs\sAt\sRisk|Mandatory\sEmail\sVerification\!|Confirm\sYour\sDelivery\sStatus|Upgrade\sMailbox|ACCOUNT\sSHUTDOWN|DE\-ACTIVATION\sREQUEST|Security\/Upgrade\sMaintainance\sready|Activate\sOne\-Time\sVerification\sOn\sYour\sEmail\sAccount|You\shave\s\{\d\}\smessages\sundelivered|Profile\sUpdate\srequired\sImmediately|Verify\sYour\sAccount\sOwnership|New\sSecure\sMessage|Action\sRequired:\sYou\shave\s\d\sblocked\smessages|^Account\sTermination\sRequest|IT\sWarning\sfor\s[a-z0-9._\-]+\@[a-z0-9.\-]+\sMailBox\sAccount|You\shave\s\[?\d+\]?\s(new\spending|undelivered)\smails|Password_Expiry_Notification|\([0-9]\)\sQuarantine\sMessages|Verify\syour\sIdentity|Mail\sQuota\sExceeded|You\shave\s\(\d+\)\sunreceived\semails\,\sget\sit\snow|Secure\sAccount\sNotice|email\saccount\sis\snearly\sfull|Suspesious\sActivity|Your\saccess\shas\sbeen\slimited|Documents\sfrom\s[a-z0-9.\-]+\.[a-z0-9.\-]+\sService|Reminder:\sYour\saccount\shas\sbeen\sdisabled\.|Confirm\syour\sinformations\sfor|Office\s365\supgrade\sand\ssecurity\supdate\snotification|Mail\sSession\sExpiration\sWarning|Mailbox\s[0-9]{2,3}\%\sUsed\sup|I\shave\sfull\scontrol\sof\syour\sdevice|Hackers\sknow\spassword\s|or\syour\saccount\swill\sbe\spermanently\slocked|Mandatory\sEmail\sVerification|Mailbox\sStorage\sFailure|You\shave\snew\sDocuments|\d+\sPending\sMassages/;

return();
}

sub lookalikes1	{
    $jr_look1 = qr/\xF0\x9F\x84\x80|\xF0\x9F\x84\x81|\xF0\x9F\x84\x82|\xF0\x9F\x84\x83|\xF0\x9F\x84\x84|\xF0\x9F\x84\x85|\xF0\x9F\x84\x86|\xF0\x9F\x84\x87|\xF0\x9F\x84\x88|\xF0\x9F\x84\x89|\xF0\x9F\x84\x8A|\xF0\x9F\x84\x8B|\xF0\x9F\x84\x8C|\xF0\x9F\x84\x8D|\xF0\x9F\x84\x8E|\xF0\x9F\x84\x8F|\xF0\x9F\x84\x90|\xF0\x9F\x84\x91|\xF0\x9F\x84\x92|\xF0\x9F\x84\x93|\xF0\x9F\x84\x94|\xF0\x9F\x84\x95|\xF0\x9F\x84\x96|\xF0\x9F\x84\x97|\xF0\x9F\x84\x98|\xF0\x9F\x84\x99|\xF0\x9F\x84\x9A|\xF0\x9F\x84\x9B|\xF0\x9F\x84\x9C|\xF0\x9F\x84\x9D|\xF0\x9F\x84\x9E|\xF0\x9F\x84\x9F|\xF0\x9F\x84\xA0|\xF0\x9F\x84\xA1|\xF0\x9F\x84\xA2|\xF0\x9F\x84\xA3|\xF0\x9F\x84\xA4|\xF0\x9F\x84\xA5|\xF0\x9F\x84\xA6|\xF0\x9F\x84\xA7|\xF0\x9F\x84\xA8|\xF0\x9F\x84\xA9|\xF0\x9F\x84\xAA|\xF0\x9F\x84\xAB|\xF0\x9F\x84\xAC|\xF0\x9F\x84\xAD|\xF0\x9F\x84\xAE|\xF0\x9F\x84\xAF|\xF0\x9F\x84\xB0|\xF0\x9F\x84\xB1|\xF0\x9F\x84\xB2|\xF0\x9F\x84\xB3|\xF0\x9F\x84\xB4|\xF0\x9F\x84\xB5|\xF0\x9F\x84\xB6|\xF0\x9F\x84\xB7|\xF0\x9F\x84\xB8|\xF0\x9F\x84\xB9|\xF0\x9F\x84\xBA|\xF0\x9F\x84\xBB|\xF0\x9F\x84\xBC|\xF0\x9F\x84\xBD|\xF0\x9F\x84\xBE|\xF0\x9F\x84\xBF|\xF0\x9F\x85\x80|\xF0\x9F\x85\x81|\xF0\x9F\x85\x82|\xF0\x9F\x85\x83|\xF0\x9F\x85\x84|\xF0\x9F\x85\x85|\xF0\x9F\x85\x86|\xF0\x9F\x85\x87|\xF0\x9F\x85\x88|\xF0\x9F\x85\x89|\xF0\x9F\x85\x8A|\xF0\x9F\x85\x8B|\xF0\x9F\x85\x8C|\xF0\x9F\x85\x8D|\xF0\x9F\x85\x8E|\xF0\x9F\x85\x8F|\xF0\x9F\x85\x90|\xF0\x9F\x85\x91|\xF0\x9F\x85\x92|\xF0\x9F\x85\x93|\xF0\x9F\x85\x94|\xF0\x9F\x85\x95|\xF0\x9F\x85\x96|\xF0\x9F\x85\x97|\xF0\x9F\x85\x98|\xF0\x9F\x85\x99|\xF0\x9F\x85\x9A|\xF0\x9F\x85\x9B|\xF0\x9F\x85\x9C|\xF0\x9F\x85\x9D|\xF0\x9F\x85\x9E|\xF0\x9F\x85\x9F|\xF0\x9F\x85\xA0|\xF0\x9F\x85\xA1|\xF0\x9F\x85\xA2|\xF0\x9F\x85\xA3|\xF0\x9F\x85\xA4|\xF0\x9F\x85\xA5|\xF0\x9F\x85\xA6|\xF0\x9F\x85\xA7|\xF0\x9F\x85\xA8|\xF0\x9F\x85\xA9|\xF0\x9F\x85\xAA|\xF0\x9F\x85\xAB|\xF0\x9F\x85\xAC|\xF0\x9F\x85\xAD|\xF0\x9F\x85\xAE|\xF0\x9F\x85\xAF|\xF0\x9F\x85\xB0|\xF0\x9F\x85\xB1|\xF0\x9F\x85\xB2|\xF0\x9F\x85\xB3|\xF0\x9F\x85\xB4|\xF0\x9F\x85\xB5|\xF0\x9F\x85\xB6|\xF0\x9F\x85\xB7|\xF0\x9F\x85\xB8|\xF0\x9F\x85\xB9|\xF0\x9F\x85\xBA|\xF0\x9F\x85\xBB|\xF0\x9F\x85\xBC|\xF0\x9F\x85\xBD|\xF0\x9F\x85\xBE|\xF0\x9F\x85\xBF|\xF0\x9F\x86\x80|\xF0\x9F\x86\x81|\xF0\x9F\x86\x82|\xF0\x9F\x86\x83|\xF0\x9F\x86\x84|\xF0\x9F\x86\x85|\xF0\x9F\x86\x86|\xF0\x9F\x86\x87|\xF0\x9F\x86\x88|\xF0\x9F\x86\x89|\xF0\x9F\x86\x8A|\xF0\x9F\x86\x8B|\xF0\x9F\x86\x8C|\xF0\x9F\x86\x8D|\xF0\x9F\x86\x8E|\xF0\x9F\x86\x8F|\xF0\x9F\x86\x90|\xF0\x9F\x86\x91|\xF0\x9F\x86\x92|\xF0\x9F\x86\x93|\xF0\x9F\x86\x94|\xF0\x9F\x86\x95|\xF0\x9F\x86\x96|\xF0\x9F\x86\x97|\xF0\x9F\x86\x98|\xF0\x9F\x86\x99|\xF0\x9F\x86\x9A|\xF0\x9F\x86\x9B|\xF0\x9F\x86\x9C|\xF0\x9F\x86\x9D|\xF0\x9F\x86\x9E|\xF0\x9F\x86\x9F|\xF0\x9F\x86\xA0|\xF0\x9F\x86\xA1|\xF0\x9F\x86\xA2|\xF0\x9F\x86\xA3|\xF0\x9F\x86\xA4|\xF0\x9F\x86\xA5|\xF0\x9F\x86\xA6|\xF0\x9F\x86\xA7|\xF0\x9F\x86\xA8|\xF0\x9F\x86\xA9|\xF0\x9F\x86\xAA|\xF0\x9F\x86\xAB|\xF0\x9F\x86\xAC|\xF0\x9F\x86\xAD|\xF0\x9F\x87\xA6|\xF0\x9F\x87\xA7|\xF0\x9F\x87\xA8|\xF0\x9F\x87\xA9|\xF0\x9F\x87\xAA|\xF0\x9F\x87\xAB|\xF0\x9F\x87\xAC|\xF0\x9F\x87\xAD|\xF0\x9F\x87\xAE|\xF0\x9F\x87\xAF|\xF0\x9F\x87\xB0|\xF0\x9F\x87\xB1|\xF0\x9F\x87\xB2|\xF0\x9F\x87\xB3|\xF0\x9F\x87\xB4|\xF0\x9F\x87\xB5|\xF0\x9F\x87\xB6|\xF0\x9F\x87\xB7|\xF0\x9F\x87\xB8|\xF0\x9F\x87\xB9|\xF0\x9F\x87\xBA|\xF0\x9F\x87\xBB|\xF0\x9F\x87\xBC|\xF0\x9F\x87\xBD|\xF0\x9F\x87\xBE|\xF0\x9F\x87\xBF/;

return();

}	

sub mytob_match {
	$mytob = qr/Your\spassword\shas\sbeen\supdated|Your\spassword\shas\sbeen\ssuccessfully\supdated|You\shave\ssuccessfully\supdated\syour\spassword|Your\snew\saccount\spassword\sis\sapproved|Your\sAccount\sis\sSuspended|\*DETECTED\*\sOnline\sUser\sViolation|Your\sAccount\sis\sSuspended\sFor\sSecurity\sReasons|Your\sservices\snear\sto\sbe\sclosed|Important\sNotification|Members\sSupport|Email\sAccount\sSuspension|Notice\sof\saccount\slimitation|YOU\sHAVE\sSUCCESSFULLY\sUPDATED\sYOUR\sPASSWORD|Your\sAccount\sis\sSuspended\sFor\sSecurity\sReasons|Members\sSupport|\*DETECTED\*\sONLINE\sUSER\sVIOLATION|\*DETECTED\*\sOnline\sUser\sViolation|fxxbpurlu|your\seBay\saccount\scould\sbe\ssuspended\sdue\supdates/;

return();
}

sub sober_match {
	$mysober = qr/\*WARNING\*\sYour\sEmail\sAccount\sWill\sBe\sClosed|Auslaenderpolitik|Augen\sauf|Graeberschaendung\sauf\sbundesdeutsche\sAnordnung|Multi\-Kulturell\=\sMulti\-Kriminell|Trotz\sStellenabbau|Massenhafter\sSteuerbetrug\sdurch\sauslaendische\sArbeitnehmer|Turkish\sTabloid\sEnrages\sGermany\swith\sNazi\sComparisons|Transparenz\sist\sdas\sMindeste|4\,8\sMill\.\sOsteuropaeer\sdurch\sFischer\-Volmer\sErlass|Vorbildliche\sAktion|Schily\sueber\sDeutschland|The\sWhore\sLived\sLike\sa\sGerman|Volk\swird\snur\szum\szahlen\sgebraucht\!|Hier\ssind\swir\sLehrer\sdie\seinzigen\sAuslaender|Vorbildliche\sAktion|Deutsche\sBuerger\strauen\ssich\snicht\s\.\.\.|Du\swirstzum\sSklaven\sgemacht\!\!\!|Paranoider\sDeutschenmoerder\skommt\sin\sPsychiatrie|Auslaender\sbevorzugt|Dresden\sBombing\sIs\sTo\sBe\sRegretted\sEnormously|Du\swirst\sausspioniert\s[\.!]+|Dresden\s1945/;
	
return();
}

sub sextortion_subject {
	$sextortion = qr/CHANGE\sYOUR\sPASSWORD\s.*\sIMMEDIATELY\.\sYOUR\sACCOUNT\sHAS\sBEEN\sHACKED\.|THIS\sACCOUNT\sHAS\sBEEN\sHACKED!\sCHANGE\sYOUR\sPASSWORD\sRIGHT\sNOW!|HACKING\sALERT!\sYOU\sACCOUNT\sWAS\sHACKED\s\(YOUR\sPASSWORD:|HIGH\sLEVEL\sOF\sDANGER\.\sYOUR\sACCOUNT|YOUR\sACCOUNT\sWAS\sUNDER\sATTACK\!\sCHANGE\sYOUR\sACCESS\sDATA\!|FRAUDSTERS\sKNOW\sYOUR\sOLD\sPASSWORDS\.|SECURITY\sALERT\.\sYOUR\sACCOUNT\sWAS\sCOMPROMISS?ED\.\sPASSWORD\sMUST\sBE\sCHANGED.|SECURITY\sNOTICE\.\sSOMEONE\sHAVE\sACCESS\sTO\sYOUR\sSYSTEM\.|BE\sSURE\sTO\sREAD\sTHIS\sMESSAGE\!|I\sCAUGHT\sYOU\sWATCHING\sPORN|THIS\sMAIL\sIS\sSENT\sTO\sYOU\sAS\sA\sLAST\sNOTICE|I\sWILL\sFORWARD\sTHE\sVIDEO\sTO\sYOUR\sFAMILY\,\sFRIENDS\sAND\sCO[\-\s]WORKERS|YOUR\sACCOUNT\sHAS\sBEEN\sHACKED\!\sYOU\sNEED\sTO\sUNLOCK\sIT\.|PLEASE\sTREAT\sAS\sA\sSERIOUS\sAND\sCONFIDENTIAL\sMATTER\,\sNOT\sAS\sSPAM|I\sCAN\sDESTROY\sYOUR\sLIFE|CAMERA\sREADY\,NOTIFICATION:\s[0-9]{2}\/[0-9]{2}\/[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}|YOUR\sPASSWORD\sIS\s.*$|YOU\sSHOULD\sBE\sASHAMED\sOF\sYOURSELF|YOUR\sPRIVACY\sIS\sIN\sDANGER|YOUR\sPRIVACY\sHAS\sBEEN\sCOMPROMISED|YOU\sHAVE\sBEEN\sRECORDED|I\sHAVE\sFULL\sCONTROL\sOF\sYOUR\sDEVICE|SECURITY\sALERT\.\sYOUR\sACCOUNTS\sWERE\sHACKED|ACCOUNT\sWAS\sUNDER\sATTACK\!\sCHANGE\sYOUR\sCREDENTIALS|ACCESS\sDATA\sMUST\sBE\sCHANGED\.|YOUR\sPERSONAL\sDATA\sIS\sTHREATENED\!|THE\sDECISION\sTO\sSUSPEND\sYOUR\sACCOUNT|PASSWORD\sMUST\sBE\sCHANGED\sNOW\./i;
	
return();
}

sub fraud_match1 {
	($count,$line) = @_;
	if ( $line =~ /([A-Za-z0-9-]{1,63}\sManagement\swould\slike\sto\sshare\san\supdate|2020\sEmail\sSecurity\.|2020\s\s\©\sAdministrator\s[a-z0-9.]+\@[a-z0-9.-]+|2020\s\©\sE\-mail\sAdmin\.|All\semail\smessages\sin\syour\spersonal\sQuarantine|Because\syou\sfailed\sto\sresolve\serrors\son\syour\semail|Blocked\s\(Important\)\sIncoming\sMessages|Click\s+below\s+and\s+follow\s+the\s+instructions\s+to\s+retain\s+your\s+email\s+account|Due\sto\sa\srecent\sconfiguration\serror\,\ssome\sof\syour\semails|Failed\sto\ssync\sand\sreturned\s\(\d\)\sincoming\smails|Follow\sbelow\sto\skeep\syour\scurrent\spassword\sand\savoid\sdata\sloss|Here\'s\sthe\sdocument\sthat\s[a-z0-9.\-]+\.[a-z0-9.\-]+\sshared\swith\syou|IT\sDesk\s©\sCopyright\s2019|If\sdon\'t\sadd\sMB\sto\syour\smail\sbox\,\syou\swill\snot\sreceive\semails|If\syou\sare\ssure\syou\sgave\sthis\sinstruction\sfor\syour\saccount\stermination\,|If\syou\sdo\snot\scomplete\,\sthe\saccount\swill\sbe\sdeactivated\.|Kindly\sre-verify\sMailbox\sto\supdate\sMailbox\sand\sstop\stemporary\sshutdown|Kindly\sre\-login\sto\skeep\ssame\spassward\sand\sto\skeep\sit\supdated|Kindly\srelease\/view\sall\srelevant\smail\sor\sdiscard\sany\sspam\smail|Kindly\srelease\sall\srelevant\smail|Kindly\supdate\syour\semail\sto\sfix\serror\snotification\smessages|MAILBOX\sSYNCHRONIZATION\sFAILED\!|Mail\sAdmin\s\(C\)\s2020\sSecured\sService|Mail\sAdministrator\swill\salways\skeep\syou\sposted\sof\ssecurity\supdates|Mail\sCenter\sHelpdesk|Mail\sdelivery\sfailed\:You\shave\s\(\d\)\snew\sdelayed\smessages|Messages\sPending\sDelivery\sOn\sYour\se\-Mail\sPortal\sSince|Microsoft\sWebmail\ssystem|request\sto\sreset\syour\spassword\sfrom\san\sunknown\slocation\.|To\sremove\slimitations\sfrom\syour\saccount\sclick\son\sthe\sfollowing\slink|upgrade\syour\smailbox\sas\ssoon\sas\spossible|before\syour\saccess\sget\ssuspended|mailbox\sis\sfuII|due\sto\supdated\sin\sour\ssystem|We\sdiscovered\sunusual\sactivities\son\syour\saccount\.|UPGRADE\sNOW\sto\sremain\ssecured|You\sneed\senroll\sfor|INCREASE\sMAILBOX\sCAPACITY|kindly\sinstructed\s\sto\supgrade\syour\smail\saccount|update\syour\saccount\swithin\s24\sHours\sof\snotice|e\-Mail\sPassword\sCenter|[A-Z0-9.\-]+\.[A-Z0-9.\-]+\sCLOUD\sSERVICES)/g ) {
		$count++;
	}
return($count);
}

sub fraud_match2 {
	($count,$line) = @_;
	if ( $line =~ /(Organization\s\:\s+administrator\s+company|Our\sserver\ssecurity\shas\sdetected\sthat\s\(\d\)\sincoming\smessages\son|PLEASE\sCONFIRM\sIF\sTHIS\sWASN\'T\s+YOU\s+by\sclicking\son\sthe\sbelow\slink|Please\sdo\snot\signore\sthis\semail\sto\savoid\syour\saccount\sclosure|Please\skindly\suse\sthe\sbutton\sbelow\sto\scontinue\swith\sthe\ssame\spassword|Please\sre\-validate\syour\smail\sserver\swithin\s24\shours|RESULT\sTO\sTERMINATION\/DELETE|Receive\sDelayed\sMessages|Reconfirm\sOwnership\sto\skeep\syour\saccount\sactive|Server\sEmail\sService\sSecurity\.|Some\sof\syour\smails\shas\sbeen\sput\son\shold|Source:\sAdministrator\sSupport|Source\:\s[a-zA-Z0-9.\-]+\.[a-zA-Z0-9.\-]+\sSupport|Synchronize\sMail\sError|The\sAccount\sTeam\s+tbi\.net|The\sunreceived\semails\swill\sbe\sdeleted\sfrom\sthe\sserver\swithin|This\smay\salso\scause\saccount\sto\slost\simportant\smails\sif\signored|This\swas\scaused\sdue\sto\sa\ssystem\sfailure|To\scontinue\susing\s[a-z0-9.]+\@[a-z0-9.-]+\s\,\skindly\sverify\sownership|Unable\sto\ssynchronize\s\[\d\]\sincomming\smails\sto\syour\saccount|Unable\sto\ssynchronize\s\[\d\]\sincomming\smails\sto\syour\saccount|Upgrade\sMailbox\sQouta|Use\sthe\sbutton\sbelow\sto\scontinue\swith\ssame\spassword|We\sdetected\sa\ssynchronization\serror\son\syour\saccount\spending\s\d\sincoming\smessages|We\sreceived\sa\srequest\sin\sour\sserver\sto\s+SHUTDOWN\s\syour\saccount|We\sreceived\syour\sinstructions\sto\sdelete\syour\semail\saccount\sfrom\sservice|WebHosting\(C\)\s2020\sSecured\sService|Web\sAdmin\sConfiguration\sTeam|Web\sAdmin\s\(C\)\s2020\sSecured\sService|Webmail\sSecurity\steam|You\scan\scontinue\susing\syour\scurrent\spassword\svia\sthe\slink\sbelow\s|You\shave\s\d+\sfailed\/unsent\smessages\son|Account\sIssue\.\sChanged\spassword\.|within\s72\shrs\sof\sreceiving\sthis\sautomated\smail|permanently\sdeactivate\syour\saccount|[a-zA-Z0-9.\-]+\.[a-zA-Z0-9.\-]+\sE\-mail\sdelivery\scenter|Dear\swebmail\sUser|currently\sundergoing\sserver\smaintenance\supgrade|MAIL\sBANDWIDTH\sLIMIT\sREACHED|Microsoft\sIT\sAdministrator\sfor|Due\sto\ssome\sabnormal\slogin\serrors|continue\swith\sthe\scurrent\sPassword|[0-9]\sNew\ssensitive\sdocuments\sassigned\sto\s\'\s?[A-Z0-9.]+\@[A-Z0-9.-]+\s?\')/g ) {
		$count++;
	}
return($count);
}

sub fraud_match3 {
	($count,$line) = @_;
	if ( $line =~ /(You\shave\s\d\squarantined\smessages\sin\syour\squarantine\smessage\sportal|Your\sAccount\sPassword\sis\sdue\sfor\sexpiration\sYesterday|Your\semail\s.(with\s)?[A-Za-z0-9]+\.[A-Za-z0-9]+\shas\sreached\san\supgrade\sstage|Your\semail\saddress\s[a-z0-9.]+\@[a-z0-9.-]+\shas\sbeen\sOutdated|Your\semail\sstorage\slimits\shas\sreached|Your\smailbox\shas\sexceeded\sits\smail\-quota\sand\sdue\sfor\supgrade|Your\smailbox\sis\sout\sof\squota\sand\swill\sreject\sall\sincoming\smails|Your\smessages\sare\snow\squeued\sup\sand\spending\sdelivery|Your\spassword\shas\sExpired\sCLICK\sHERE\s\sTo\sVerify|[a-z0-9.]+\@[a-z0-9.-]+\s+Online\s+Office|[a-z0-9.]+\@[a-z0-9.-]+\sDe\-activation\sNotice|[a-z0-9.]+\@[a-z0-9.-]+\sMail\sAdmin|[a-z0-9.]+\@[a-z0-9.-]+\sOnline\sMaintenance\sPortal|[a-z0-9.]+\@[a-z0-9.-]+\sSupport\sTeam|[a-z0-9.]+\@[a-z0-9.-]+\sWebApp\sAlert|[a-z0-9.]+\@[a-z0-9.-]+\sWebMail\sTeam|[a-z0-9.]+\@[a-z0-9.-]+\saccount\squota|[a-z0-9.]+\@[a-z0-9.-]+\ssecurity\smanagement|\@2020\sE\-mail\sverify|\b[A-Za-z0-9]+\.[A-Za-z0-9]+\sMailBox\sManagement\sCenter|\©\s2020\sAccount\sTeam|\©\sEMAIL\sINC\.\s2020|access\sincoming\smessages\sand\sto\savoid\smail\smalfunction|access\sto\syour\s\sMail\sAccount\swill\sbe\sDenied|account\swill\sbe\sOfficially\sPermanently|an\sautomated\sbehavior\sthat\sviolates\sour\sRules|click\son\sthe\sbutton\sbelow\sto\scancel\sthe\sdeactivation\srequest|closing\sall\sold\sversion\sof\stbi\.net|clustered\son\syour\scloud\sdue\sto\slow\semail\sstorage\scapacity\sdetected|confimation\sto\savoid\smail\smalfunction|disable\sthe\s\"Quota\:\:MailboxWarning\"\stype\sof\snotification|documents\shas\sbeen\sshared\swith\syou\son\s[a-z0-9._\-]+\@[a-z0-9.\-]+\sSharepoint\sStorage|download\spending\semails\sand\scontinue\sto\sreceive\semails\son\syou|Your\spassword\swill\sexpire\sin\sdays\stime\sfrom\snow|So\swe\shave\sLimited\syour\sAccount|your\saccount\ssecurity\sis\soutdated|your\saccess\shas\sbeen\slimited\.\slimited\.|IT\sHelpdesk\sSupport|new\sSecurity\sand\sUpgrade\sCheckup|RE\-VALIDATION\sREQUIRED\sTO\sUNBLOCK\sPENDING\sMAILS|We\sneed\sto\svalidate\syou\sas\sthe\sowner\sof\sthis\semail|your\spassword\sis\sdue\sfor\sexpiration)/g ) { 
		$count++;
	}
return($count);
}

sub fraud_match4 {
	($count,$line) = @_;
	if ( $line =~ /(due\sto\sinvalidation\sof\syour\smailbox|due\sto\ssecurity\slevel\slift\son\smail\sserver|exceeded\sits\smail\-quota\sand\sdue\sfor\supgrade|follow\sthe\ssteps\sto\sconfirm\sthat\syou\sare\sthe\svalid\saccount\sowner|has\sbeen\sused\sin\ssending\sBulk\smessage\sthis\swill\scause\syour\smailbox|has\sfailed\sto\sdeliver\s\[\d\]\snew\semails\sfrom\ssome\sof\syour\scontacts|if\syou\sdo\snot\scancel\sthis\srequest\syour\smail\swill\sbe\sshutdown\sshortly|kindly\sCancel\sRequest\sbelow\sto\supgrade|kindly\suse\sthe\sbelow\sto\scontinue\swith\ssame\spassword|lead\sto\sPermanent\sclosure\sof\sAccount|mailbox\sto\sbe\stemporarily\sclosed\suntil\sre-verification\sprocess|ownership\son\s[a-z0-9.]+\@[a-z0-9.-]+\sserver|problem\sverifying\syour\sidentity\swe\s|recover\sthese\smessages\sby\svalidating\syour\smailbox|release\sall\srelevant\smail\sor\sDiscard|review\syour\sundelivered\semails\sand\sautomatcally\sresend\semail\srequest|sign\sin\sNow\sto\sRelease\s+Message\son\syour\se\-Mail\sAccount|since\syou\shave\sQuarantine\snotification|stop\sthe\srequest\,\sif\sit\swas\smade\sin\serror\sor|suspended\sfrom\sthe\sonline\smaintenance\sservice\sdatabase|this\swas\scaused\sdue\sto\sa\ssystem\sdelay|to\sDeactivate\sall\sold\smail\sversions|visit\sthe\slink\sbelow\sto\srestore\saccess\syour\semail|will\sbe\sdisconnected\sfrom\ssending\sand\sreceiving\semails\sfrom\sother\susers|will\snot\sbe\sheld\sresponsible\sfor\syour\smailbox\smalfunction|you\scan\supgrade\sto\sextra\s+25GB\splan|your\smail\sto\savoid\sautomatic\sclosure\sof\syour\soutlook\smail|Anti\-Spam\sSystem\sfor|Clear\smailing\schannel\snow|Please\sclear\syour\smailing\schannel\simmediately|Server\sEmail\sDeactivation\sNotice\.|You\shave\spending\sincoming\semails\sthat\syou\sare\syet\sto\sreceive|[a-z0-9.]+\@[a-z0-9.-]+\sadministrator(\'s)?\spolicy|\(C\)\s2020\ssecurity\sservices|has\sbeen\slisted\sfor\stermination\scheck\sattached\sfor\smore\sdetails|update\syour\saccount\snow\sto\sget\smore\semail\sspace\squota|webmail\sSecurity\sTeam|your\smailing\schannel\sis\scleared|[a-zA-Z0-9.\-]+\.[a-z0-9.\-]+\sE\-mail\sSync\sFailure\.|©\s20[0-9]{2}\sWEBMAIL\sAccounts|e\-mail\saccount\swill\sbe\sdisable\sfrom|Sign\sin\sto\sAccess\sUpgrade)/g ) {
		$count++;
	}
return($count);
}

sub fraud_match5 {
	($count,$line) = @_;
	if ( $line =~ /(INCOMING\sMAILS\sPLACED\sON\sHOLD|\xC2\xA9Mailbox\.|We\sfound\s\d+\sincoming\sundelivered\semails\smostly\sfrom\syour\scontacts|avoid\stemporarily\sservice\sinterruption|awaiting\syour\saction\sto\sbe\sdelivered\sto\s\(\s+[a-z0-9.]+\@[a-z0-9.-]+|button\sbelow\sto\sFix\-Error\sNow|by\sthe\ssystem\sto\sby\snotification\sonly|IT\sHelpdesk\sService|STATUS\:\sPENDING\sMAILS|Update\sYour\sBlockchain\sHere\sNow|I\.T\sAdminnotice|Your\se\-mail\sPassword\shas\sexpired|Pdf\sfile\son\sour\ssecure\sserver\sfor\syour\sview\sonly|messages\sthat\sare\srejected\sdue\sto\sserver\serror|allow\smails\sand\sadd\sMemory|message\susing\sMicrosoft\sonedrive|This\smessage\swas\ssent\sto\s[a-z0-9.]+\@[a-z0-9.-]+\s\;\s\;|pending\smassage\sdue\sto\snetwork|Mail\swill\sbe\sdelivered\sto\syour\sinbox\safter\sclicking\srelease)/g ) {
		$count++;
	}
return($count);
}

sub fname_match {
	$fname1 = qr/Aaron|Abe|Abigail|Abraham|Abby|Adam|Adrian|Adriana|Adrianna|Ahmed|Aisha|Alan|Alastair|Alex|Alexa|Alexandra|Alexis|Alice|Alicia|Alinka|Alison|Allen|Allison|Allyssa|Althea|Alyson|Alyssa|Albert|Alfred|Althea|Amanda|Amelia|Amber|Amelia|Amy|Ana|Anabelle|Andrea|Andrew|Andy|Andrea|Angel|Angela|Angelique|Angelo|Anita|Ann|Anna|Annabelle|Anne|Annette|Annie|Anthony|Antoinette|Antonin|April|Arnold|Aron|Ashley|Ashton|Aspen|Audrey|Aubrey|Auslar|Austin|Autumn|Ava|Avery|Axel|Barbara|Barney|Barry|Bartoov|Basil|Beatrice|Becky|Belinda|Belle|Ben|Benno|Benny|Benson|Bernadette|Bernard|Bernie|Berry|Bertha|Beryl|Beth|Bethany|Betty|Beulah|Beverly|Bianca|Bill(y|ie)?|Bintou|Blaine|Blair|Blake|Bob|Bobbie|Bobby|Bonnie|Boris|Brad|Bradley|Brandi|Brady|Brandon|Brayden|Brenda|Brendan|Brianna|Brent|Brett|Brian|Brianna|Brie|Britt?|Brittany|Brody|Brooke|Brooklynn|Bryan|Bryce|Buford|Caitlin|Cal|Caleb|Candace|Candice|Candy|Cara|Caren|Carie|Carl|Carla|Carlo|Carlos|Carly|Carmen|Carol|Caroline|Carolyn|Carrie|Carry|Carter|Casey|Cass|Cassandra|Catherine|Cathy|Cecelia|Cecil|Cecilia|Celine|Chad|chancery|Chantelle|Charlena|Charles|Charlie|Charlotte|Chase|Chelsea|Cherish|Cherry|Cheryl|Chester|Chet|Cheyenne|Chloe|Choi|Chris|Christina|Christine|Christopher|Cindy|Clair|Claire|Clara|Clare|Clarence|Clarice|Clarke?|Clarisse|Clarissa|Clay|Clayton|Clifton|Clyde|Cody|Colin|Collin|Connie|Conrad|Constance|Consuelo|Corey|Cory|Craig|Cruisines|Cynthia|Daisy|Dan|Dana|Danah|Daniel/i;
	$fname2 = qr/Danielle|Danny|Daphna|Daphne|Darla|Darlene|Darrell?|Darryl|Daryl|Dave|Davia|David|Dawn|Dawson|Dean|Debbie|Debby|Deborah|Debra|Delta|Denise|Dennis|Derek|Desdemona|Devin|Devon|Dexter|Diana|Diane|DHD|Dina|Dino|Dolores|Donn|Donna|Doreen|Doris|Doug|Douglas|Drew|Drone|Durham|Eddie|Eddy|Eden|Edith|Edward|Eileen|Elaine|Elena|Elizabeth|Elizaveta|Ellen|Emma|Emmanuel|Emily|Eric|Erica|Erik|Erika|Ernest|Estelle|Ester|Ethan|Ethel|Eugene|Evan|Eve|Evelyn|Faith|Faroline|Farrah|Fatima|Faviola|Felicia|Felix|Florence|Floyd|Fluent|Francis|Frank|Franklin|Fred|Freddy|Frederick|Gabby|Gabe|Gabrella|Gabriel|Gabriella|Gadie|Gail|Garrett|Gary|Gavin|Gayle|Gaylord|Geneva|George|Georgia|Gerald|Geraldo|Gil|Gilbert|Gilberto|Giselle|Glaucia|Gloria|Godwin|Gordon|Grant|Greco|Greg|Guillermo|Gus|Gwen|Hadi|Hal|Haley?|Hamilton|Hank|Hannah|Harold|Harry|Hazel|Heather|Heidi|Helen|Helena|Henrietta|Henry|Herk|Herm|Holly|Hollie|Hollis|Hope|Hoss|Howard|Hugo|Ian|Imogen|Ingrid|Ira|Irene|Isabella|Israel|Ivan|Jack|Jackie|Jackson|Jacky|Jacob|Jade|Jai|Jake|James|Jamie|Jan|Jana|Jane|Jared|Jason|Jasmine|Janet|Janice|Jason|Jay(la)?|Jean|Jeb|Jeff|Jefferson|Jeffery|Jeffrey|Jeanette|Jenn|Jenna|Jennifer|Jenny|Jeremy|Jerold|Jess|Jesse|Jessica|Jessie|Jesus|jethro|Jill|Jillian|Jim|Jimenez|Jimmy|Joan|Joanne|Jocelyn|Jodi|Jody|Joe|Joel|Joey|Johan|John|Johnny|Johnathan|Jon|Jonathan|Jonna|Jordan|Jose|Josefin|Joseph|Josephine|Josh|Joshua|Joy|Joyce|Juan|Juanita|Judith|Judy|Julia|Juliana|Julie|Juliet|Julio|Juliya|Justin|Justine/i;
	$fname3 = qr/Kaleb|Karen|Karim|Karl|Karlie|Kasey|Kat|Kate|Katherine|Kathleen|Kathryn|Kathy|Katie|Katrina|Katy|Kay|Kayden|Kayla|Keegan|Keith|Kelly|Kelsey|Ken|Kendra|Kenneth|Kenny|Kevin|Khloe|Kim|Kimberly|Kirk|Kirsten|Klaus|Krause|Krista|Kristan|Kristen|Kristin|kristine|Kurt|Kyle|Kylie|Laarni|Lance|Lancer|Lady|Landon|Lana|Lanny|Laraine|Larisa|Larry|Lars|Latasha|Laura|Lauran|Lauren|Laurie|Lawrence|Lazaro|Leah|Lee|Leigh|Leon|Leonardo|Leslie|Lewis|Liam|Liane|Lilia|Lilian|Linda|Lindsay|Lindsey|linmda|Lionel|Lis|Lisa|Liu|Logan|Lois|Lola|Lora|Lorraine|Lori|Lou|Louis|Louise|Lubna|Lucas|Lucy|Lucille|Luis|Luke|Lula|Luna|Lyle|Lynette|Lynn|Lyubov|Mack|Mackenzie|Madelaine|Madeline|Maggie|Madison|Malai|Malcolm|Malinda|Mallory|Mandy|Manuel|Marcel|Marco|Marcus|Marcie|Margaret|Marge|Margie|Margo|Mark|Marlene|Marley|Matt|Maria|Mariam|Marianne|Marietta|Marilyn|Mario|Marion|Marissa|Mariya|Marshall|Martha|Martin|Martina|Marvin|Mary|Marylin|Marylyn|Matt|Matthew|Mathias|Mavis|Max|Maxine|Megan|Mel|Melanie|mellanie|Melinda|Melissa|Mellisa|Melvin|Mendoza|Mercy|Meredith|Meri|Mia|Michael|Micheal|Michelle|Miguel|Mike|Miles|Millie|Milo|Minnie|Mirku|Missoula|Missula|Mitch|Mitchell|Mohammad|Molly|Monica|Monique|Monu|Moran|Morgan|Morris|Muriel|Nadia|Nadine|Nancy|Nash|Natalia|Natalie|Natasha|Nate|Nathan|Nathaniel|Naty|Ned|Nell|Nelson|Ngozi|Nicholas|Nick|Nicole|Nigel|Nina|Noah|Norbert|Norman|Olga|Oliva|Olive|Olivia|Olive|Oliver|Oxana|Page|Pam|Pamela|Pancho|Paris|Parker|Pat|Patricia|Patrick|Patti|Pattie|Patty|Paul|Paula|Pearl|Pedro|Pepe|Pete|Peter|Phil|Philips|Phillip/i;
	$fname4 = qr/Phoebe|Phyllis|Porter|Preston|Priscilla|Priya|Rachel|Ralph|Randall?|Randy|Raquel|Rashad|Rashmi|Raul|Raven|Raymond|Rebecca|Regina|Remi|Renee?|Ricardo|Rich|Richard|Rick|Ricky|Riley|Rita|Rob|Robbie|Robert|Robin|Rocco|Rocky|Roger|Roland|Rolando|Ron|Rona|Ronald|Ronnia|Rosa|Rosaline|Rosalina|Rosanne|Roscoe|Rose|Rosie|Ross|Rosy|Rowan|Roxana|Roxanne|Roy|rvsleju|Ruby|Russell|Ruth|Ryan|Sabrina|Sage|Sally|Sam|Samir|Sammy|Samantha|Sandra|Sandy|Santos|Sara|Sarah|Sarita|Saul|Savannah|Scarlett|Scotty?|Sean|Sergio|Seth|Sevgi|Shamir|Shane|Shannon|Sharon|Shaun|Shavonda|Shayla|Sheila|Shelley|Shelly|Sheri|Sherry|Shia|Shirley|Sidney|Skyler|Snow|Sofia|Sonia|Sophia|Sophie|Spencer|Stacey|Stacy|Stan|Stanley|Stef|Stella|Stephan|Stephanie|Stephen|Stephie|Stephine|Steve|Steven|Stokes|Stuart|Summer|Sung|Sunie|Sunny|Susan|Susie|Suzanne|Suzy|Sven|Sylvia|Sydney|Tabitha|Tamara|Tammy|Tanya|Tara|Tatiana|Tawney|Taylor|Teresa|Terry|Theodore|Theresa|Thomas|Tiffany|Tim|Timothy|Tina|Todd|Tom|Tomi|Tommy|Toni|Tonia|Tony|Tonny|Tory|Tracy|Travis|Trevor|Trieu|Tristan|Tucker|Tyrone|Ursula|Valerie|Vance|Vanessa|Vann|Vera|Veronica|Vickie|Victor|Victoria|Vincent|Violet|Viktoriya|Virginia|Vivian|Vlad|Vladimir|Vonda|Wade|Walter|Wanda|Ward|Warren|WebMed|Wendy|Wes|Wesley|Whitney|Will|William|Willie|Willis|Wilma|Wong|Woodtai|Yolanda|Yvonne|Zach|Zachary|Zainab|Zoe/i;
	$fname_plus = qr/Mr|Mrs|Ms|Miss|Sir|Engr|Engineer|Adv|Advocate|Mgr|Manager|Barrister|Solicitor|Esq|Esquire|Attorney|Prof|Professor|Sgt|Capt|Diplomat|Engr|From/i;
	
return();
}
	
	
# This ;1 is important
1;
