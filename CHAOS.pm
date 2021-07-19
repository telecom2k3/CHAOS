package Mail::SpamAssassin::Plugin::CHAOS;

our $VERSION = "1.2.1";
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



### DIAGNOSTICS WITH VERBOSITY ###
### See Also: Mail/SpamAssassin/Util/DependencyInfo.pm
### perl /$PATH_TO/CHAOS.pm [-v, --version]   # CHAOS.pm, PERL, SA Version             
### perl /$PATH_TO/CHAOS.pm [-V, --verbose]   # Above + PERL libraries for SA
### perl /$PATH_TO/CHAOS.pm [-VV, --very]     # Above + SA physical file paths
if ( defined $ARGV[0] ) {
    if ( $ARGV[0] =~ /-v|--version|-V|--verbose|-VV|--very/ ) {  
        print "CHAOS v$VERSION\n";
        print "PERL $^V\n";
        my $module = "Mail::SpamAssassin";
        my $errorCount = 0;
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
            ++$errorCount;
        } else {
            my $version = $module->VERSION;
            $version =~ s/00/\./g;
            $version =~ s/\.\./\./g;
            print "SpamAssassin v$version\n";
        }
    }
    if ( $ARGV[0] =~ /-V|--verbose|-VV|--very/ ) {  
        print "-----\n";
        $module = "Archive::Tar";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "BSD::Resource";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Compress::Zlib";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "DB_File";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "DBI";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Digest::MD5";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Digest::SHA1";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Encode";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Encode::Detect";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Encode::Detect::Detector";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Errno";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "File::Basename";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "File::Copy";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "File::Path";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "File::Spec";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Geo::IP";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "GeoIP2::Database::Reader";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Getopt::Long";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "HTML::Parser";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "HTTP::Date";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Socket::INET";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Socket::INET6";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Socket::IP";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Socket::SSL";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Socket::UNIX";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::String";
        eval "require $module;";
        if (my $error = $@) {
            print "*** $module: Not Found! ***\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IO::Zlib";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IP::Country";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "IP::Country::DB_File";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "LWP::UserAgent";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Mail::DKIM";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Mail::SPF";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "MIME::Base64";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "MIME::QuotedPrint";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "NetAddr::IP";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::CIDR::Lite";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::DNS";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::DNS::Nameserver";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::DNS::Resolver";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::Ident";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::Patricia";
        $errorCount = 0;
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Net::DNS";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "NetAddr::IP";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Pod::Usage";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "POSIX";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Razor2::Client::Agent";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Sys::Hostname";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Sys::Syslog";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Term::ReadKey";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Test::More";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Time::HiRes";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Time::Local";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            my $version = $module->VERSION;
            print "$module v$version\n";
        }
        $module = "Unicode::UCD";
        eval "require $module;";
        if (my $error = $@) {
            print "$module: Not Found!\n";
        } else {
            use Unicode::UCD;
            my $version = $module->UnicodeVersion;
            print "Unicode v$version\n";
        }
    }
    if ( $ARGV[0] =~ /-VV|--very/ ) {  
        print "-----\n";
        foreach $line (@INC) {
            print `find /usr/local/share/perl/5.26.1 -type f -path *SpamAssassin*`;
        }
    }
}


=pod
 
=head1 NAME

Mail::SpamAssassin::Plugin::CHAOS

    Version: 1.2.1
    Name: "Harmony"


=head1 SYNOPSIS

=over 5

=item  Usage:

    ifplugin Mail::SpamAssassin::Plugin::CHAOS
        chaos_mode Manual
        header      JR_UNIBABBLE        eval:from_lookalike_unicode()
        describe    JR_UNIBABBLE        From Name Character Spoofs
        score       JR_UNIBABBLE        3.0
        ...
        header      JR_SUBJ_EMOJI       eval:check_for_emojis()
        header      JR_FRAMED_WORDS     eval:framed_message_check()
        header      JR_TITLECASE        eval:subject_title_case()
        ...
    endif
       
=back

=over 5 

=item  This module adds a little "Awesome Sauce" to your SpamAssassin installation.

=back

=head1 DESCRIPTION
 
This is a SpamAssassin module that provides a variety of: Callouts, Handlers, And Other Stuff (CHAOS).  To acquire Ordo Ab Chao, this SpamAssassin plugin provides over 20 unique Eval rules.  It does a lot of counting.


This plugin demonstrates SpamAssassin's relatively new (3.4) dynamic scoring capabilities:

    + Use PERL's advanced arithmetic functions.
    + Dynamic, Variable, and Conditional scoring.
    + Adaptive scoring (baseline reference).

This module can operate in the following modes:

=over 5

=item "Tag" mode sets the scores for all rules produced to a callout level of 0.01.  You can add or change rulenames using these Evals, but the description and soore remain fixed.  This is useful when first integrating this module into an existing SA system.  This is the default mode of operation.

=item "Manual" mode allows you, the user, to set the Name, Describe, and Score fields for each Eval; in traditional SA fashion.  A couple of notes about Manual mode: (1) If a DESCRIBE field is not set, the module's Eval routing will provide one.  (2) If a SCORE is not set, the Eval routine will return a callout value of 0.01 for the rule.

=item "AutoISP" mode allows you to quickly scale the rules to ranges suitable for ISP/ESP use. 

=back

=head2  Adaptive Scoring Configuration

=over 5

=item

The rules provided by thie module are auto-scoring.  The scores are set to
a percentage of the value at which mail is Tagged as Spam.
This value is set in the .cf configuration file.

For example, if a particular rule scores 4.5 on this mail system, the rule
score would be something like: $score = $pms->{conf}->{chaos_tag} * 0.64.  
Changing this value will increase or decrease ALL scores provided by 
this module in Auto mode.

    Default Values
    --------------
    chaos_tag 7
    
=item  

In a pure-play, basic SpamAssassin environment, try setting this to 4.
    
=back

=cut

=head1 METHODS

=over 5

=item  This plugin provides many Eval routines, called in standard fashion from local SpamAssassin ".cf" configuration files.
=item  Most of these Eval routines can be passed a COUNT value in the parenthesis ().

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
    $self->register_eval_rule("check_subj_brackets");
    $self->register_eval_rule("check_from_brackets");
    $self->register_eval_rule("framed_message_check");
    $self->register_eval_rule("framed_digit_check");
    $self->register_eval_rule("check_for_emojis");
    $self->register_eval_rule("check_from_emojis");
    $self->register_eval_rule("check_replyto_emojis");
    $self->register_eval_rule("useless_utf_check");
    $self->register_eval_rule("from_lookalike_unicode");
    $self->register_eval_rule("subj_lookalike_unicode");
    $self->register_eval_rule("from_enclosed_chars");
    $self->register_eval_rule("subj_enclosed_chars");
    $self->register_eval_rule("subject_title_case");
    $self->register_eval_rule("check_replyto_length");
    $self->register_eval_rule("check_reference_doms");
    $self->register_eval_rule("check_cc_public_name");
    $self->register_eval_rule("check_to_public_name");
    $self->register_eval_rule("check_pub_shorturls");
    $self->register_eval_rule("check_priv_shorturls");
    $self->register_eval_rule("systeminfo");
    $self->register_eval_rule("check_apple_device");
    $self->register_eval_rule("check_admin_fraud");
    $self->register_eval_rule("check_admin_fraud_body");
    $self->register_eval_rule("mailer_check");
    $self->register_eval_rule("check_honorifics");
    $self->register_eval_rule("from_in_subject");
    $self->register_eval_rule("id_attachments");
    $self->register_eval_rule("first_name_basis");
    $self->register_eval_rule("from_no_vowels");
    $self->register_eval_rule("check_email_greets");
    
    # and return the new plugin object
    #
    # Kerplunk.  Good luck, kid.
    return $self;
}

sub set_config {
    my ($self, $conf) = @_;
    my @cmds = ();
    push (@cmds, {
        setting => 'chaos_mode',
        default => 'Tag',
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_STRING,
    });
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
        default => 25,
        type => $Mail::SpamAssassin::Conf::CONF_TYPE_NUMERIC,
    });
    
    $conf->{parser}->register_commands(\@cmds);
    
return();
}


=head2  check_subj_brackets()

Default()=7

=over 5

=item This is a Subject header test for Left and Right, Brackets, Braces, Parenthesis and their Unicode varients.  These are sometimes called Set, Framing, or Grouping Characters.  In Tag mode, JR_SUBJ_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR_SUBJ_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR_RULENAME> is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, in the standard SpamAssassin fashion.

=back

=over 5

=item  In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR_SUBJ_BRACKETS or <YOUR_RULENAME> is appended with an "_$count" whose score is 0.01. Example: YOUR_RULENAME_3.

=back

=cut

sub check_subj_brackets {

    local ( $self, $pms, $max ) = @_;
    local $subject = $pms->get('Subject:raw');
    local $leftcount = () = $subject =~ /\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B/g;
    local $rightcount = () = $subject =~ /\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D/g;
    local $totalcount = $leftcount + $rightcount;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_BRACKETS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Subject has many brackets";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
        
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 7;
    } 
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.13 * ($totalcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Create callout rule containing the raw amount of set chars.
    if ($totalcount > 0) {
        $score = 0.01;
        if ($totalcount >= 10) {
            $rulename .= "_10+";
        } else {
            $rulename .= "_$totalcount";
        }
        $description = "CHAOS: Subject bracket count: $totalcount";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
return 0;
}

=head2  check_from_brackets()

Default()=5

=over 5

=item  This is a test of the From Name field for Left, Right, Brackets, Braces, Parenthesis and their Unicode varients.  In Tag mode, JR_FROM_BRACKETS is set to a callout value of 0.01.  In AutoISP mode, JR_FROM_BRACKETS is variable based upon the number of brackets over the limit.  In Manual mode, <YOUR_RULENAME> is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, in the standard SpamAssassin fashion.

=back

=over 5

=item  In ALL modes, a callout is set containing the exact number of bracket characters detected.  The rulename, JR_FROM_BRACKETS or <YOUR_RULENAME> is appended with an "_$count" whose score is 0.01. Example: YOUR_RULENAME_3.

=back

=cut

sub check_from_brackets {

    local ( $self, $pms, $max ) = @_;
    local $subject = $pms->get('From:name');
    local $leftcount = () = $subject =~ /\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B/g;
    local $rightcount = () = $subject =~ /\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D/g;
    local $totalcount = $leftcount + $rightcount;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FROM_BRACKETS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description ) || ( $mode ne "Manual" )) {
        $description = "CHAOS: From Name has many brackets";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if (( ! defined  $score ) || ( $mode ne "Manual" )) {
        $score = 0.01;
    }
        
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 5;
    } 
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.18 * ($totalcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Create callout rule containing the raw amount of set chars.
    if ($totalcount >= 1) {
        $score = 0.01;
        if ($totalcount >= 10) {
            $rulename .= "_10+";
        } else {
            $rulename .= "_$totalcount";
        }
        $description = "CHAOS: Frome Name has $totalcount brackets";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
return 0;
}


=head2  framed_message_check()

Default()=1

=over 5

=item  This is a Subject header test that looks for the presence of Framed / 
Bracketed words, lie: [URGENT].  All standard Parens, Brackets, and Braces are 
supported, along with Unicode variants!  In The Auto and Tag modes, the rule's 
description will reflect the number of instances found.


=back

=over 5  

=item  In Auto mode this score is variable, based upon the number of matches at or above
the defined count.  The default() count is 1.  When running in Tag mode, the score is
set to a callout level of 0.01.

=back

=cut


sub framed_message_check {
    local ( $self, $pms, $max ) = @_;
    local $subject = $pms->get('Subject');
    local @count = $subject =~ /(\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?(NOTICE|OCTOBER|WEBCAST|URGENT|DOWNLOAD|ACTION|PAYPAL|PROPERTY|GUIDE|LIVE|TOMORROW|NEW|WEBINAR|IVENTIUM|TODAY|ENGINEER|UPDATE|UPDATES|STATEMENT|INVOICE|PURCHASE|VIDEO|SURVEY|SALE|YYT|CMD|PAYMENT\sSTATEMENT\sRECEIPT|ACTION\sREQUIRED|ACTION\sNEEDED|TRANSACTION\sREPORT\sAUTHORIZATION|ACCOUNT\sREVIEW|ACCOUNT\sALERT|CASH\sOFFER|PROCEED\sTO\sRESOLVE\sNOW|PAYMENT\sSTORE\sCONFIRMED|DETAILS\sABOUT|EXTERNAL\sSENDER|LAST\sCHANCE|FREE|IMPORTANT|IMPORTANT\sUPDATE|SUSPEND|IMPORTANT\sACTION|REPORT\sINFORMATION|SST|AMAZON\sSTATEMENT\sREPORT|GMT\+[0-9]{1,2}|NEWS\sSTATEMENT\sREPORT|E\-RECEIPT\sCONFIRMATION|ACCOUNT\sHOLDER|PAYMENT\sINFORMATION|ALIBABA\sINQUIRY\sNOTIFICATION|REPORT\sCONFIRMATION|ORDER\sRECEIPT\sREPORT|BILLING\sREPORT\sINFORMATION|URGENT\sREPLY)\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D)/gi;
    @count = grep defined, @count; 
    local $framed = scalar @count;
    $framed = $framed / 3;
    local $set = 0;
    local $score = 0.01;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FRAMED_WORDS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description ) || ( $mode ne "Manual" )) {
            $description = "CHAOS: Unique Framed Words Detected: $framed";
    }
    $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if (( ! defined $score ) || ( $mode ne "Manual" )) {
        $score = 0.01;
    }

    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 1;
    }
    
    if ( $framed >= $max ) {
        if ( $mode eq "AutoISP" ) { 
            $score = ($pms->{conf}->{chaos_tag} * 0.25) * ($framed - $max + 1);
        } 
        
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 

    }

return 0;
}

=head2  framed_digit_check()

Default()=2

=over 5

=item  This is a Subject header test that looks for the presence of Framed / 
Bracketed digits [4].  All standard Parens, Brackets, and Braces are 
supported, along with Unicode variants.  In The Auto and Tag modes, the 
rule's description will reflect the number of instances found.  

=back

=over 5

=item  In Auto mode, the score is variable, based upon the number of framed
digits at, or over, the defined count.  The default() count is 2.


=back

=cut
 
sub framed_digit_check {
    local ( $self, $pms, $max ) = @_;
    local $subject = $pms->get('Subject');
    local $set = 0;
    local $score = 0.01;
    local @count = $subject =~ /((\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?[0-9]{1,2}\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D))/g;
    @count = grep defined, @count; 
    local $framed = ( scalar @count / 3 );
    local @utfcount = $subject =~ /((\[|\(|\{|\xE3\x80\x90|\xE3\x80\x88|\xE3\x80\x94|\x28|\x7B|\x5B)\s?(\xEF\xBC\x90|\xEF\xBC\x91|\xEF\xBC\x92|\xEF\xBC\x93|\xEF\xBC\x94|\xEF\xBC\x95|\xEF\xBC\x96|\xEF\xBC\x97|\xEF\xBC\x98|\xEF\xBC\x99|\xEF\xBD\xAD|\xEF\xBD\xAE|\xEF\xBE\x95|\xEF\xBE\x96){1,2}\s?(\]|\)|\}|\xE3\x80\x91|\xE3\x80\x89|\xE3\x80\x95|\x29|\x7D|\x5D))/g;
    @utfcount = grep defined, @utfcount; 
    local $utfframed = ( scalar @utfcount / 3 );
    $framed = $framed + $utfframed;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FRAMED_DIGITS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description ) || ( $mode ne "Manual" )) {
        $description = "CHAOS: Framed Digits in Subject: $framed";
    }
    $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if (( ! defined $score ) || ( $mode ne "Manual" )) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 2;
    }
    
    $max++;
    if ( $framed >= $max ) {
        if ( $mode eq "AutoISP" ) { 
            $score = ($pms->{conf}->{chaos_tag} * 0.25) * ($framed - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Create callout rule containing the raw amount of framed digits.
    if ($framed >= 1) {
        $score = 0.01;
        if ($framed >= 10) {
            $rulename .= "_10+";
        } else {
            $rulename .= "_$framed";
        }
        $description = "CHAOS: Frome Name has $framed brackets";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  check_for_emojis()

Default()=3

=over 5

=item  This is a Subject header test that looks for Unicode Emojis.  In Tag 
mode JR_SUBJ_EMOJIS, or <YOUR_RULENAME>, is set to a callout value of 0.01.  
In AutoISP mode, JR_SUBJ_EMOJIS has a variable score based upon the number 
of Emojis at, exceeding, the hit count.  In Manual mode, <YOUR_RULENAME> 
is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, in the standard 
SpamAssassin fashion.  The Default() hit count is 3.

=back

=over 5

=item  In ALL modes, a callout is set containing the exact number of bracket 
characters detected.  The rulename, JR_SUBJ_EMOJIS or <YOUR_RULENAME> is 
appended with an "_$count" whose score is 0.01. Example: YOUR_RULENAME_3. 
The rule's description will reflect the number of Emojis found.

=back

=cut


# There are thousands and thousands of Emojis.  This is not a complete list,
# but it should pick up most of them.
sub check_for_emojis {
    # https://www.utf8-chartable.de/unicode-utf8-table.pl
    local ( $self, $pms, $max ) = @_;
    local $subject1 = $pms->get('Subject');
    &emoji_hunt();
    
    # Using Global Vars defined as TypeDef UniCode.  Otherwise, have
    # problems passing UniCode Vars defined in sub-routines, like the
    # Unicode QR pre-defined query strings returned from &emoji_hunt.
    # Something about Private vars...
    local $emojis1 = () = $subject1 =~ /$jr_line1/g;
    local $emojis2 = () = $subject1 =~ /$jr_line2/g;
    local $emojis3 = () = $subject1 =~ /$jr_line3/g;
    local $emojis4 = () = $subject1 =~ /$jr_line4/g;
    local $emojis5 = () = $subject1 =~ /$jr_line5/g;
    local $totalcount = $emojis1 + $emojis2 + $emojis3 + $emojis4 + $emojis5;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_EMOJIS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description ) || ( $mode ne "Manual" )) {
        $description = "CHAOS: Subject Emoji 2 Many";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 3;
    }
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.15 * ($totalcount - $max + 1);
        }
        
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "HEADER: ", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Output callout rule containing the total count.
    if ($totalcount > 0) {
        $score = 0.01;
        if ($totalcount >= 10) {
            $rulename .= "_10+";
        } else {
            $rulename .= "_$totalcount";
        }
        $description = "CHAOS: Subject Emohji count: $totalcount";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Re-init the QR variables with Unicode Type.
    $jr_line1 = "\xC7\xC7\xC7\xC7";
    $jr_line2 = "\xC7\xC7\xC7\xC7";
    $jr_line3 = "\xC7\xC7\xC7\xC7";
    $jr_line4 = "\xC7\xC7\xC7\xC7";
    $jr_line5 = "\xC7\xC7\xC7\xC7";
    
return 0;
}

=head2  check_from_emojis()

Default()=1

=over 5

=item  This is a test of the From Name field that looks for Unicode Emojis.  
In Tag mode JR_FROM_EMOJIS, or <YOUR_RULENAME>, is set to a callout value of 
0.01.  In AutoISP mode, JR_FROM_EMOJIS has a variable score based upon the 
number of Emojis at, or exceeding, the hit count.  In Manual mode, 
<YOUR_RULENAME> is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, 
in the standard SpamAssassin fashion. 

=back

=cut


# There are thousands and thousands of Emojis.  This is not a complete list,
# but it should pick up most of them.
sub check_from_emojis {
    # https://www.utf8-chartable.de/unicode-utf8-table.pl
    local ( $self, $pms, $max ) = @_;
    local $subject1 = $pms->get('From:name');
    &emoji_hunt();
    
    # Using Global Vars defined as TypeDef UniCode.  Otherwise, have
    # problems passing UniCode Vars defined in sub-routines, like the
    # Unicode QR pre-defined query strings returned from &emoji_hunt.
    # Something about Private vars...
    local $emojis1 = () = $subject1 =~ /$jr_line1/g;
    local $emojis2 = () = $subject1 =~ /$jr_line2/g;
    local $emojis3 = () = $subject1 =~ /$jr_line3/g;
    local $emojis4 = () = $subject1 =~ /$jr_line4/g;
    local $emojis5 = () = $subject1 =~ /$jr_line5/g;
    local $totalcount = $emojis1 + $emojis2 + $emojis3 + $emojis4 + $emojis5;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FROM_EMOJIS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: An Emoji 2 Many in From Name";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 3;
    }
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.15 * ($totalcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Re-init the QR variables with Unicode Type.
    $jr_line1 = "\xC7\xC7\xC7\xC7";
    $jr_line2 = "\xC7\xC7\xC7\xC7";
    $jr_line3 = "\xC7\xC7\xC7\xC7";
    $jr_line4 = "\xC7\xC7\xC7\xC7";
    $jr_line5 = "\xC7\xC7\xC7\xC7";
    
return 0;
}

=head2  check_replyto_emojis()

Default()=1

=over 5

=item  This tests the Reply-To Name field for Unicode Emojis. 
In Tag mode JR_FROM_EMOJIS, or <YOUR_RULENAME>, is set to a callout value of 
0.01.  In AutoISP mode, JR_FROM_EMOJIS has a variable score based upon the 
number of Emojis at, or exceeding, the hit count.  In Manual mode, 
<YOUR_RULENAME> is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, 
in the standard SpamAssassin fashion. 

=back

=cut


# There are thousands and thousands of Emojis.  This is not a complete list,
# but it should pick up most of them.
sub check_replyto_emojis {
    # https://www.utf8-chartable.de/unicode-utf8-table.pl
    local ( $self, $pms, $max ) = @_;
    local $subject1 = $pms->get('Reply-To:name');
    &emoji_hunt();
    
    # Using Global Vars defined as TypeDef UniCode.  Otherwise, have
    # problems passing UniCode Vars defined in sub-routines, like the
    # Unicode QR pre-defined query strings returned from &emoji_hunt.
    # Something about Private vars...
    local $emojis1 = () = $subject1 =~ /$jr_line1/g;
    local $emojis2 = () = $subject1 =~ /$jr_line2/g;
    local $emojis3 = () = $subject1 =~ /$jr_line3/g;
    local $emojis4 = () = $subject1 =~ /$jr_line4/g;
    local $emojis5 = () = $subject1 =~ /$jr_line5/g;
    local $totalcount = $emojis1 + $emojis2 + $emojis3 + $emojis4 + $emojis5;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_REPLYTO_EMOJIS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: An Emoji 2 Many in the Reply-To Name";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 3;
    }
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.15 * ($totalcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # Re-init the QR variables with Unicode Type.
    $jr_line1 = "\xC7\xC7\xC7\xC7";
    $jr_line2 = "\xC7\xC7\xC7\xC7";
    $jr_line3 = "\xC7\xC7\xC7\xC7";
    $jr_line4 = "\xC7\xC7\xC7\xC7";
    $jr_line5 = "\xC7\xC7\xC7\xC7";
    
return 0;
}


=head2  useless_utf_check()

Default()=4

=over 5

=item This tests the Subject for useless UTF-8 characters and hits when the
defined count is reached.  In Tag mode JR_SUBJ_UTF_MISUSE, or <YOUR_RULENAME>,
is set to a callout value of 0.01.  In AutoISP mode, JR_SUBJ_UTF_MISUSE has a
variable score based upon the number of these UTF characters at, or over, the
limit.  

=back

=over 5

=item In Manual mode, <YOUR_RULENAME> is scored with whatever <YOUR_SCORE> 
and <YOUR_DESCRIBE>, in the standard SpamAssassin fashion. 

=back

=over 5

=item  The Default() hit count is 4.

=back

=cut

sub useless_utf_check {
    # https://www.utf8-chartable.de/unicode-utf8-table.pl
    local ( $self, $pms, $max ) = @_;
    local $subject1 = $pms->get('Subject');
    local $unicrap1 = () = $subject1 =~ /\xE2\x80\xAA|\xE2\x80\xAB|\xE2\x80\xAC|\xE2\x80\xAD|\xE2\x80\xAE|\xE2\x80\xAF|\xE2\x80\x8B|\xE2\x80\x8C|\xE2\x80\x8D|\xE2\x80\x8C|\xE2\x80\x90|\xE2\x80\x91|\xE2\x81\xA1|\xE2\x81\xA2|\xE2\x81\xA3|\xE2\x81\xA4|\xE2\x9D\xB6|\xE2\x9C\x89|\xEF\xBB\xBF|\xF0\x9F\x9A\x85/g;

    local $totalcount = $unicrap1;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_UTF_MISUSE";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Subject contains many useless UTF-8 characters";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 4;
    }
    
    if ($totalcount >= $max) {
        if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.18 * ($totalcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
return 0;
}

=head2  from_lookalike_unicode()

Default()=1

=over 5

=item  This checks the From Name field for the presence of multiple Unicode
Alphabets.  Spammers use these "Look-Alike" characters for spoofing.  This 
sets the maximum number of Alphabets that can appear here.  This is almost
always 1; a single Character Code Set.  This will detect most of the From 
Name character spoofs.

=back

=over 5

=item  In Tag mode JR_UNIBABBLE, or <YOUR_RULENAME>, is set to a callout 
value of 0.01.  In Manual mode JR_UNIBABBLE, or <YOUR_RULENAME>, may be 
Scored and Described in standard SA fashion. 

=back

=over 5

=item  In Tag mode JR_UNIBABBLE, or <YOUR_RULENAME>, is scored at a callout 
value of 0.01.  In Manual mode JR_UNIBABBLE, or <YOUR_RULENAME>, may be 
Scored and Described in standard SA fashion.   In Auto mode, JR_UNIBABBLE
is scored variably, depending upon the amount over the defined threshold.

=back

=over 5

=item  Countries with LATIN-2 alphabets (ISO 8859-2/8859-3) should set
the count to 2: from_lookalike_unicode(2).

=back

=cut

# Look-alike characters in a name?  How many code sets does one need?
sub from_lookalike_unicode {
    local ( $self, $pms, $max ) = @_;
    local $code = 0;
    local $set = 0;
    local $ascii = 0;
    local $cyrl = 0;
    local $greek = 0;
    local $latin2 = 0;
    local $mideast = 0;
    local $output = 0;
    local $from = $pms->get('From:name');
    $from =~ tr/0-9//d;
    local $target = $from;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_UNIBABBLE";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: From Name contains mixed Unicode Alphabets";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 1;
    }
    # ASCII
    if ( $from =~ /[a-zA-z\,\+\-_\:]/g ) {
        $ascii++;
        $code++;
    }
    # GREEK
    &utfgreek1($target);
    if ( $output >= 1 ) { 
        $greek++;
        $code++; 
    }
    $output = 0;
    # CYRILIC/COPTIC/GREEK
    &utfcyrilic1($target); 
    if ( $output >= 1 ) { 
        if ( $greek > 0 ) {
            $greek++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # LATIN EXT-B
    &utflatin_extb($target); 
    if ( $output >= 1 ) { 
        $latin2++;
        $code++; 
    }
    $output = 0;
    # LETTER-LIKE SYMBOLS
    &utf_letterlike($target); 
    if ( $output >= 1 ) { 
        $code++; 
    }
    $output = 0;
    # LATIN SUPPLEMENT
    &utflatin_sup($target); 
    # don't increment in conjunction with ASCII
    if (( $output >= 1 ) && ( $ascii == 0 )) { 
        $code++; 
    }
    $output = 0;
    # LATIN EXT-A
    &utflatin_exta($target); 
    if (( $output >= 1 ) && ( $latin2 == 0 )) { 
        $latin2++;
        $code++; 
    }
    $output = 0;
    # LATIN 1-SUP Undefined Controls.
    if ( $from =~ /\xC2\x80|\xC2\x81|\xC2\x82|\xC2\x83|\xC2\x84|\xC2\x85|\xC2\x86|\xC2\x87|\xC2\x88|\xC2\x89|\xC2\x8A|\xC2\x8B|\xC2\x8C|\xC2\x8D|\xC2\x8E|\xC2\x8F|\xC2\x90|\xC2\x91|\xC2\x92|\xC2\x93|\xC2\x94|\xC2\x95|\xC2\x96|\xC2\x97|\xC2\x98|\xC2\x99|\xC2\x9A|\xC2\x9B|\xC2\x9C|\xC2\x9D|\xC2\x9E|\xC2\x9F/g ) {
        $code++;
    }
    # CYRILLIC2
    &utf_cyrilic2($target); 
    if ( $output >= 1 ) { 
        if ( $cyrl > 0 ) {
            $cyrl++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # CYRILLIC3
    &utf_cyrilic3($target); 
    if ( $output >= 1 ) { 
        if ( $cyrl > 0 ) {
            $cyrl++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # ARABIC
    &utf_arabic1($target); 
    if ( $output >= 1 ) { 
        if ( $mideast > 0 ) {
            $mideast++;
        } else {
            $mideast++;
            $code++; 
        }
    }
    $output = 0;
    # HEBREW
    &utf_hebrew1($target); 
    if ( $output >= 1 ) { 
        if ( $mideast > 0 ) {
            $mideast++;
        } else {
            $mideast++;
            $code++; 
        }
    }
    $output = 0;
    # ENCLOSED
    &encased1($target);
    $code4 = $output;
    $output = 0;
    # ENCLOSED
    &encased2($target);
    $code4 = $code4 + $output;
    $output = 0;
    # MATH_ALPHAS
    &mathalpha($target);
    $code4 = $code4 + $output;
    $output = 0;
    # CJK_FORMS
    &cjkforms($target);
    $code4 = $code4 + $output;
    $output = 0;
    
    if ( $code4 >= 1 ) { 
        $code++; 
    }
    
    if ($code > $max) {
        if ( $mode eq "AutoISP" ) { 
                $description = "CHAOS: From Name contains mixed Unicode Alphabets: $code";
                $score = $pms->{conf}->{chaos_tag} * 0.8;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  subj_lookalike_unicode()

Default()=1

=over 5

=item  This checks the email Subject for the presence of multiple Unicode
Alphabets.  Spammers use these "Look-Alike" characters for spoofing.  This 
sets the maximum number of Alphabets that can appear here.  Usually a value
of 1 works, but some Some professionals and academia may want to set this 
value to 2 to accomodate Math or Engineering Unicode symbols.

=back

=over 5  

=item  In Tag mode JR_SUBJ_BABBLE, or <YOUR_RULENAME>, is set to a callout 
value of 0.01.  In Manual mode JR_SUBJ_BABBLE, or <YOUR_RULENAME>, may be 
Scored and Described in standard SA fashion.  In Auto mode, JR_SUBJ_BABBLE
is scored variably, depending upon the amount over the defined threshold.

=back

=over 5

=item  Countries with LATIN-2 alphabets (ISO 8859-2/8859-3) should set
the count to 2: subj_lookalike_unicode(2).

=back

=cut


sub subj_lookalike_unicode {
    local ( $self, $pms, $max ) = @_;
    local $code = 0;
    local $set = 0;
    local $ascii = 0;
    local $cyrl = 0;
    local $greek = 0;
    local $latin2 = 0;
    local $mideast = 0;
    local $output = 0;
    local $from = $pms->get('Subject');
    $from =~ tr/0-9//d;
    local $target = $from;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_BABBLE";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Subject contains multiple Unicode Alphabets";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 1;
    }
    # ASCII
    if ( $from =~ /[a-zA-Z]/g ) {
        $ascii++;
        $code++;
    }
    # GREEK
    &utfgreek1($target);
    if ( $output >= 1 ) { 
        $greek++;
        $code++; 
    }
    $output = 0;
    # CYRILIC/COPTIC/GREEK
    &utfcyrilic1($target); 
    if ( $output >= 1 ) { 
        if ( $greek > 0 ) {
            $greek++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # LATIN EXT-B
    &utflatin_extb($target); 
    if ( $output >= 1 ) { 
        $latin2++;
        $code++; 
    }
    $output = 0;
    # LETTER-LIKE SYMBOLS
    &utf_letterlike($target); 
    if ( $output >= 1 ) { 
        $code++; 
    }
    $output = 0;
    # LATIN SUPPLEMENT
    &utflatin_sup($target);
    if (( $output >= 1 ) && ( $ascii == 0 )) { 
        $code++; 
    }
    $output = 0;
    # LATIN EXT-A
    &utflatin_exta($target); 
    if (( $output >= 1 ) && ( $latin2 == 0 )) { 
        $latin2++;
        $code++; 
    }
    $output = 0;
    # LATIN 1-SUP Undefined Controls.
    if ( $from =~ /\xC2\x80|\xC2\x81|\xC2\x82|\xC2\x83|\xC2\x84|\xC2\x85|\xC2\x86|\xC2\x87|\xC2\x88|\xC2\x89|\xC2\x8A|\xC2\x8B|\xC2\x8C|\xC2\x8D|\xC2\x8E|\xC2\x8F|\xC2\x90|\xC2\x91|\xC2\x92|\xC2\x93|\xC2\x94|\xC2\x95|\xC2\x96|\xC2\x97|\xC2\x98|\xC2\x99|\xC2\x9A|\xC2\x9B|\xC2\x9C|\xC2\x9D|\xC2\x9E|\xC2\x9F/g ) {
        $code++;
    }
    # CYRILLIC2
    &utf_cyrilic2($target); 
    if ( $output >= 1 ) { 
        if ( $cyrl > 0 ) {
            $cyrl++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # CYRILLIC3
    &utf_cyrilic3($target); 
    if ( $output >= 1 ) { 
        if ( $cyrl > 0 ) {
            $cyrl++;
        } else {
            $cyrl++;
            $code++; 
        }
    }
    $output = 0;
    # ARABIC
    &utf_arabic1($target); 
    if ( $output >= 1 ) { 
        if ( $mideast > 0 ) {
            $mideast++;
        } else {
            $mideast++;
            $code++; 
        }
    }
    $output = 0;
    # HEBREW
    &utf_hebrew1($target); 
    if ( $output >= 1 ) { 
        if ( $mideast > 0 ) {
            $mideast++;
        } else {
            $mideast++;
            $code++; 
        }
    }
    $output = 0;
    # ENCLOSED
    &encased1($target);
    $code4 = $output;
    $output = 0;
    # ENCLOSED
    &encased2($target);
    $code4 = $code4 + $output;
    $output = 0;
    # MATH_ALPHAS
    &mathalpha($target);
    $code4 = $code4 + $output;
    $output = 0;
    # CJK_FORMS
    &cjkforms($target);
    $code4 = $code4 + $output;
    $output = 0;
    if ( $code4 >= 1 ) { 
        $code++; 
    }

    if ($code > $max) {
        if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.8;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  from_enclosed_chars()

Default()=3

=over 5

=item  This checks the From Name field for the presence of Unicode Enclosed/
Encircled and Mathematical Latin characters.  These are often used in spam. 

=back

=over 5

=item  In Tag mode JR_FROM_ENC_CHARS, or <YOUR_RULENAME>, is set to a 
 callout value of 0.01.  In Auto mode, JR_FROM_ENC_CHARS is scored variably, 
 depending upon the amount over the defined threshold.

=back

=over 5

=item  In Manual mode JR_FROM_ENC_CHARS, or <YOUR_RULENAME>, may be Scored and 
 Described in standard SA fashion. 


=back

=cut


sub from_enclosed_chars {
    my ( $self, $pms, $max ) = @_;
    local $code4 = 0;
    local $set = 0;
    local $output = 0;
    local $from = $pms->get('From:name');
    local $target = $from;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FROM_ENC_CHARS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description) || ( $mode ne "Manual" )) {
        $description = "CHAOS: From Name contains many Encircled/Enclosed Characters";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if (( ! defined $score ) || ( $mode ne "Manual" )) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 3;
    }
    # ENCLOSED
    &encased1($target);
    $code4 = $code4 + $output;
    $output = 0;
    # ENCLOSED
    &encased2($target);
    $code4 = $code4 + $output;
    $output = 0;
    # MATH_ALPHAS
    &mathalpha($target);
    $code4 = $code4 + $output;
    $output = 0;
    # CJK_FORMS
    &cjkforms($target);
    $code4 = $code4 + $output;
    $output = 0;
    if ( $code4 >= $max ) { 
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.22 * ($code4 - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  subj_enclosed_chars()

Default()=3

=over 5

=item  This checks the email Subject for the presence of Unicode Enclosed/
Encircled Latin characters.  These are often used in spam. 

=back

=over 5

=item  In Tag mode JR_SUBJ_ENC_CHARS, or <YOUR_RULENAME>, is set to a 
 callout value of 0.01.  In Auto mode, JR_SUBJ_ENC_CHARS is scored variably, 
 depending upon the amount over the defined threshold.

=back

=over 5

=item  In Manual mode JR_SUBJ_ENC_CHARS, or <YOUR_RULENAME>, may be Scored 
 and Described in standard SA fashion. 


=back

=cut


sub subj_enclosed_chars {
    my ( $self, $pms, $max ) = @_;
    local $code4 = 0;
    local $set = 0;
    local $output = 0;
    local $from = $pms->get('Subject');
    local $target = $from;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_ENC_CHARS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if (( ! defined $description) || ( $mode ne "Manual" )) {
        $description = "CHAOS: Subject contains many Encircled/Enclosed/Math Characters";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if (( ! defined $score ) || ( $mode ne "Manual" )) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 3;
    }
    # ENCLOSED
    &encased1($target);
    $code4 = $code4 + $output;
    $output = 0;
    # ENCLOSED
    &encased2($target);
    $code4 = $code4 + $output;
    $output = 0;
    # MATH_ALPHAS
    &mathalpha($target);
    $code4 = $code4 + $output;
    $output = 0;
    # CJK_FORMS
    &cjkforms($target);
    $code4 = $code4 + $output;
    $output = 0;
    if ( $code4 >= $max ) { 
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.22 * ($code4 - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  subject_title_case()

Default()=4

=over 5

=item This is a Subject header test that detects the presence of all Title Case
(Proper Case) words.  The rule, JR_TITLECASE, is set with a fixed score in Auto
mode and a 0.01 callout value in Tag mode.  In Manual mode, <YOUR_RULENAME> 
is scored with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>, in the standard 
SpamAssassin fashion.

=back

=over 5

=item  The number of words that must be in the Subject is a tunable value.  The
default value() is 4.

=back

=cut

sub subject_title_case {

    local ( $self, $pms, $max ) = @_;
    local $subject = $pms->get('Subject');
    $subject =~ s/[^[[:upper:][:lower:][:digit:]]]//g;
    local $wcount = 0;
    local $tcount = 0;
    local $ucount = 0;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_TITLE_CASE";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Subject is in Title/Proper Case";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 4;
    }
    foreach my $word (split('\s+',$subject)) {
        $wcount++;
        if ( $word =~ /^[[:upper:]]+$/g ) {
            $ucount++;
            $tcount++;
        } elsif ( $word =~ /^[[:upper:][:digit:]][[:upper:][:lower:][:digit:]]*$/g ) {
            $tcount++;
        # Preposition filter
        } elsif ( $word =~ /^(for|in|and|on|of|to|a|the|these|at|be|under|off|over|near|with|down|by|above|from|into|upon|onto|out|within|after|before|below|near|among|between|amidst|behind)$/g ) {
            $tcount++;
        # Filter short adjectives
        } elsif ( $word =~ /^(my|our|is|your)$/g ) {
            $tcount++;
        }       
    }

    if (( $tcount == $wcount ) && ( $wcount != $ucount ) && ( $wcount >= $max )) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.2;
        }
        
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    # $description = "CHAOS: Words=$wcount Title=$tcount Upper=$ucount";
    # $pms->{conf}->{descriptions}->{"$rulename"} = $description;
    # $pms->got_hit("$rulename", "HEADER: ", score => $score);
    # $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 

return 0;
}

=head2  check_replyto_length()

Default()=175

=over 5

=item  This checks the length of the Reply-To field.  When the length is
excessive the rule, JR_LONG_REPLYTO, is set.  This is a fixed score in
Auto mode and a 0.01 callout value in Tag mode.  In Manual mode, 
<YOUR_RULENAME> is scored  with whatever <YOUR_SCORE> and <YOUR_DESCRIBE>,
in the standard  SpamAssassin fashion. 

=back

=over 5

=item  The number of *characters* that can appear in the Reply-To field is
tunable.  The default value() is 175.

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
    local $rto = $pms->get('Reply-To');
    local $size = length($rto);
    local $score = 0.01;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_LONG_REPLYTO";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Reply-To is lengthy: $size";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 175;
    }
    
    if ($size > $max) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.37;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  check_reference_doms()

Default()=10

=over 5

=item  This counts the number of domain references within any the Reference: 
Header field. When this number is set the rule, JR_REF_XS_DOM, is set.  
The count of domain references is displayed in the default description.

=back

=over 5

=item  This rule is scored at a callout level of 0.01 in Tag mode and a fixed
score in auto mode.  In Manual mode, <THIS_RULENAME> is scored  with whatever 
<THIS_SCORE> and <THIS_DESCRIBE>, in the standard  SpamAssassin fashion. 

=back

=cut


sub check_reference_doms {
    my ( $self, $pms, $max ) = @_;
    local $ref = $pms->get('References');
    local $score = 0.01;
    local $set = 0;
    local $count = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    $count = () = $ref =~ /\@[a-zA-Z0-9\.\-]{2,50}\.[a-zA-Z]{2,10}\b/g;

    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_REF_XS_DOM";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Reference Header has many domain references: $count";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 10;
    }
    
    if ($count >= $max) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.32;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  check_cc_public_name()

Default()=25

=over 5

=item  This is a Header test of the CC field.  If a valid Name cannot be found
and the number of CC Email Addresses hits a tunable number, then the rule, 
JR_CC_PUB_NONAME, is set (In Auto mode).  In Manual mode the rule's name, the 
description, and the score can be set as needed.  In Tag mode, the score is 
fixed at a 0.01 callout level.

=back

=over 5

=item  The default() number of CC Email Addresses that must be present is 25.

=back

=over 5

=item  Public Emails are not necessarily FREEMAILs.  These Email addresses
include common Network/Carrier addresses, like "verizon.net" or "comcast.net".
These represent the top 100 or so Email systems, world-wide.

=back

=over 5


=back

=cut

sub check_cc_public_name {
    my ( $self, $pms, $max ) = @_;
    local $ccaddr = $pms->get('Cc', undef);
    local $name = "";
    local $set = 0;
    local $score = 0.01;
    if ( defined $ccaddr ) {
        $ccaddr =~ s/\R//g;
        my $pubmails = qr/gmail\.com|yahoo\.com|hotmail\.com|aol\.com|hotmail\.co\.uk|hotmail\.fr|msn\.com|yahoo\.fr|wanadoo\.fr|orange\.fr|comcast\.net|yahoo\.co\.uk|yahoo\.com\.br|yahoo\.co\.in|live\.com|rediffmail\.com|free\.fr|gmx\.de|web\.de|yandex\.ru|ymail\.com|libero\.it|outlook\.com|uol\.com\.br|bol\.com\.br|mail\.ru|cox\.net|hotmail\.it|sbcglobal\.net|sfr\.fr|live\.fr|verizon\.net|live\.co\.uk|googlemail\.com|yahoo\.es|ig\.com\.br|live\.nl|bigpond\.com|terra\.com\.br|yahoo\.it|neuf\.fr|yahoo\.de|alice\.it|rocketmail\.com|att\.net|laposte\.net|facebook\.com|bellsouth\.net|yahoo\.in|hotmail\.es|charter\.net|yahoo\.ca|yahoo\.com\.au|rambler\.ru|hotmail\.de|tiscali\.it|shaw\.ca|yahoo\.co\.jp|sky\.com|earthlink\.net|optonline\.net|freenet\.de|t-online\.de|aliceadsl\.fr|virgilio\.it|home\.nl|qq\.com|telenet\.be|me\.com|yahoo\.com\.ar|tiscali\.co\.uk|yahoo\.com\.mx|orange\-business\.fr|voila\.fr|gmx\.net|mail\.com|planet\.nl|tin\.it|live\.it|ntlworld\.com|arcor\.de|yahoo\.co\.id|frontiernet\.net|hetnet\.nl|live\.com\.au|yahoo\.com\.sg|zonnet\.nl|club-internet\.fr|juno\.com|optusnet\.com\.au|blueyonder\.co\.uk|bluewin\.ch|skynet\.be|sympatico\.ca|windstream\.net|mac\.com|icloud\.com|centurytel\.net|chello\.nl|live\.ca|aim\.com|bigpond\.net\.au|bt\.net|bt\.com|vodamail\.co\.za|inbox\.ru|zohomail\.com|tutanota\.com|trashmail\.com|fastmail\.com|hushmail\.com|safe\-mail\.net|hotmail\.co\.jp|docomo\.co\.jp|excite\.co\.jp|qq\.com|163\.com|126\.com|foxmail\com|sina\.com|sina\.cn|t\-online\.de|seznam\.cz|yahoo\.co\.uk|attglobal\.net|juno\.com|emirates\.net\.ae|fibertel\.com\.ar|mindspring\.com|[a-z]{2,20}\.rr\.com|btconnect\.com|t\-online\.hu|terra\.com\.mx|uol\.com\.ar|uol\.com\.mx|fastwebnet\.it|21cn\.com|live\.com\.ar|poste\.it|bluemail\.ch/im;
        local $count = () = $ccaddr =~ /[[:upper:][:lower:][:digit:]\.\_\-\+]+\@($pubmails)/g;
        $ccaddr =~ s/[[:upper:][:lower:][:digit:]\.\_\-\+]+\@[[:upper:][:lower:][:digit:]\.\_\-\+]+\b//g;
        $ccaddr =~ s/\W//g;
        if ( $ccaddr =~ /\w/g ) {
            $count = 0;
        }
        
        local $mode = $pms->{conf}->{chaos_mode};
        local $rulename = $pms->get_current_eval_rule_name();
        if (($rulename eq '') || ($mode eq "AutoISP")) {
            $rulename = "JR_CC_PUB_NONAME";
        }
        local $description = $pms->{conf}->{descriptions}->{"$rulename"};
        if ((!defined($description)) || ($mode ne "Manual")) {
            $description = "CHAOS: Many CCs but no name: $count";
        }
        local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
        if ((!defined($score)) || ($mode ne "Manual")) {
            $score = 0.01;
        }
        
        if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 25;
        }
        
        if ( $count >= $max) {
            if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.29;
            }
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
return 0;
}   

=head2  check_to_public_name()

Default()=50

=over 5

=item  This is a Header test of the TO field.  If a valid Name cannot be found
and the number of TO Email Addresses hits a tunable number, then the rule, 
JR_TO_PUB_NONAME, is set (In Auto mode).  In Manual mode the rule's name, the 
description, and the score can be set as needed.  In Tag mode, the score is 
fixed at a 0.01 callout level.

=back

=over 5

=item  The default() number of TO Email Addresses that must be present is 50.

=back

=over 5

=item  Public Emails are not necessarily FREEMAILs.  These Email addresses
include common Network/Carrier addresses, like "verizon.net" or "comcast.net".
These represent the top 100 or so Email systems, world-wide.

=back

=cut

sub check_to_public_name {
    my ( $self, $pms, $max ) = @_;
    local $toaddr = $pms->get('To', undef);
    local $name = "";
    local $set = 0;
    local $score = 0.01;
    if ( defined $toaddr ) {
        $toaddr =~ s/\R//g;
        my $pubmails = qr/gmail\.com|yahoo\.com|hotmail\.com|aol\.com|hotmail\.co\.uk|hotmail\.fr|msn\.com|yahoo\.fr|wanadoo\.fr|orange\.fr|comcast\.net|yahoo\.co\.uk|yahoo\.com\.br|yahoo\.co\.in|live\.com|rediffmail\.com|free\.fr|gmx\.de|web\.de|yandex\.ru|ymail\.com|libero\.it|outlook\.com|uol\.com\.br|bol\.com\.br|mail\.ru|cox\.net|hotmail\.it|sbcglobal\.net|sfr\.fr|live\.fr|verizon\.net|live\.co\.uk|googlemail\.com|yahoo\.es|ig\.com\.br|live\.nl|bigpond\.com|terra\.com\.br|yahoo\.it|neuf\.fr|yahoo\.de|alice\.it|rocketmail\.com|att\.net|laposte\.net|facebook\.com|bellsouth\.net|yahoo\.in|hotmail\.es|charter\.net|yahoo\.ca|yahoo\.com\.au|rambler\.ru|hotmail\.de|tiscali\.it|shaw\.ca|yahoo\.co\.jp|sky\.com|earthlink\.net|optonline\.net|freenet\.de|t-online\.de|aliceadsl\.fr|virgilio\.it|home\.nl|qq\.com|telenet\.be|me\.com|yahoo\.com\.ar|tiscali\.co\.uk|yahoo\.com\.mx|orange\-business\.fr|voila\.fr|gmx\.net|mail\.com|planet\.nl|tin\.it|live\.it|ntlworld\.com|arcor\.de|yahoo\.co\.id|frontiernet\.net|hetnet\.nl|live\.com\.au|yahoo\.com\.sg|zonnet\.nl|club-internet\.fr|juno\.com|optusnet\.com\.au|blueyonder\.co\.uk|bluewin\.ch|skynet\.be|sympatico\.ca|windstream\.net|mac\.com|icloud\.com|centurytel\.net|chello\.nl|live\.ca|aim\.com|bigpond\.net\.au|bt\.net|bt\.com|vodamail\.co\.za|inbox\.ru|zohomail\.com|tutanota\.com|trashmail\.com|fastmail\.com|hushmail\.com|safe\-mail\.net|hotmail\.co\.jp|docomo\.co\.jp|excite\.co\.jp|qq\.com|163\.com|126\.com|foxmail\com|sina\.com|sina\.cn|t\-online\.de|seznam\.cz|yahoo\.co\.uk|attglobal\.net|juno\.com|emirates\.net\.ae|fibertel\.com\.ar|mindspring\.com|[a-z]{2,20}\.rr\.com|btconnect\.com|t\-online\.hu|terra\.com\.mx|uol\.com\.ar|uol\.com\.mx|fastwebnet\.it|21cn\.com|live\.com\.ar|poste\.it|bluemail\.ch/im;
        local $count = () = $toaddr =~ /[[:upper:][:lower:][:digit:]\.\_\-\+]+\@($pubmails)/g;
        $toaddr =~ s/[[:upper:][:lower:][:digit:]\.\_\-\+]+\@[[:upper:][:lower:][:digit:]\.\_\-\+]+\b//g;
        $toaddr =~ s/\W//g;
        if ( $toaddr =~ /\w/g ) {
            $count = 0;
        }
        
        local $mode = $pms->{conf}->{chaos_mode};
        local $rulename = $pms->get_current_eval_rule_name();
        if (($rulename eq '') || ($mode eq "AutoISP")) {
            $rulename = "JR_TO_PUB_NONAME";
        }
        local $description = $pms->{conf}->{descriptions}->{"$rulename"};
        if ((!defined($description)) || ($mode ne "Manual")) {
            $description = "CHAOS: Many TO addresses but no name: $count";
        }
        local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
        if ((!defined($score)) || ($mode ne "Manual")) {
            $score = 0.01;
        }
        
        if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 50;
        }
        
        if ( $count >= $max) {
            if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.29;
            }
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
return 0;
}

=head2  check_pub_shorturls()

Default()=1

=over 5

=item  This is a test of URIs in the message body, looking for URL Shortener
services.  These services are grouped as Public (bit.ly, etc.) and Private 
(wpo.st, etc.).  When a match is found, the rule JR_PUB_SHORTURL (in Auto
 mode) is set and the scoring of the rule is variable depending upon the count
 of Public URL Shorteners found above the defined limit, which is 1 by default.

=back

=over 5

=item  In Tag mode, the rule  The rule, JR_PUB_SHORTURL or <YOUR_RULENAME>
 is set to a callout value of 0.01.  In Manual mode, the rule can be <NAMED>,
 <DESCRIBED> and <SCORED> in standard SpamAssassin fashion.

=back

=cut

sub check_pub_shorturls {
    my ( $self, $pms, $max ) = @_;
    local $uris = $pms->get_uri_detail_list();
    local $pubcount = 0;
    local $set = 0;
    local $score = 0.01;
    while (my($uri, $info) = each %{$uris}) {
        next unless ($info->{domains});
        foreach ( keys %{ $info->{domains} } ) {
            if ( $uri =~  /https?:\/\/(.{1,15}\.)?(0rz\.tw|1l2\.us|1link\.in|1url\.com|1u\.ro|2big\.at|2chap\.it|2\.gp|2\.ly|2pl\.us|2su\.de|2tu\.us|2ze\.us|301\.to|301url\.com|307\.to|3\.ly|4ms\.me|4url\.cc|6url\.com|7\.ly|9mp\.com|a2a\.me|a2n\.eu|aa\.cx|abbr\.com|abcurl\.net|abe5\.com|access\.im|adf\.ly|adjix\.com|ad\.vu|afx\.cc|a\.gd|a\.gg|aim\.co\.id|all\.fuseurl\.com|alturl\.com|amishdatacenter\.com|amishprincess\.com|a\.nf|ar\.gy|arm\.in|arst\.ch|asso\.in|atu\.ca|aurls\.info|awe\.sm|ayl\.lv|azc\.cc|azqq\.com|b23\.ru|b2l\.me|b65\.com|b65\.us|back\.ly|bacn\.me|bc\.vc|bcool\.bz|beam\.to|bgl\.me|bin\.wf|binged\.it|bit\.do|bit\.ly|bitly\.com|bkite\.com|bl\.ink|blippr\.com|bloat\.me|blu\.cc|bon\.no|branch\.io|bsa\.ly|bt\.io|budurl\.com|buff\.ly|buk\.me|burnurl\.com|buzurl\.com|canurl\.com|catsnthing\.com|catsnthings\.fun|cc\.uz|cd4\.me|chatter\.com|chilp\.it|chopd\.it|chpt\.me|chs\.mx|chzb\.gr|clck\.ru|cliccami\.info|clickthru\.ca|cli\.gs|clicky\.me|clipurl\.us|clk\.im|clk\.my|cl\.lk|cl\.ly|clkim\.com|cloaky\.de|clop\.in|clp\.ly|coge\.la|c-o\.in|cokeurl\.com|conta\.cc|cort\.as|cot\.ag|crabrave\.pw|crks\.me|crum\.pl|c\.shamekh\.ws|ctvr\.us|cur\.lv|curio\.us|curiouscat\.club|cuthut\.com|cutt\.ly|cutt\.us|cuturl\.com|cuturls\.com|cutwin\.biz|db\.tt|decenturl\.com|deck\.ly|df9\.net|dfl8\.me|digbig\.com|digipills\.com|digs\.by|disçordapp\.com|dld\.bz|dlvr\.it|dn\.vc|doiop\.com|doi\.org|do\.my|dopen\.us|dr\.tl|drudge\.tw|durl\.me|durl\.us|dvlr\.it|dwarfurl\.com|easyuri\.com|easyurl\.net|ebay\.to|eca\.sh|eclurl\.com|eepurl\.com|eezurl\.com|erq\.io|eweri\.com|ewerl\.com|ezurl\.eu|fa\.by|faceto\.us|fav\.me|fbshare\.me|fff\.to|ff\.im|fhurl\.com|filoops\.info|fire\.to|firsturl\.de|firsturl\.net|flic\.kr|flingk\.com|flq\.us|fly2\.ws|fn\.tc|fon\.gs|forms\.gle|formspring\.me|fortnight\.space|fortnitechat\.site|foxyurl\.com|freak\.to|freegiftcards\.co|fur\.ly|fuseurl\.com|fuzzy\.to|fw\.to|fwd4\.me|fwdurl\.net|fwib\.net|g8l\.us|gameptp\.com|get\.sh|get-shorty\.com|get-url\.com|geturl\.us|gg\.gg|gi\.vc|gizmo\.do|gkurl\.us|gl\.am|go2\.me|go2l\.ink|go\.9nl\.com|gog\.li|go\.ign\.com|golmao\.com|good\.ly|goshrink\.com|go\.to|gowal\.la|gplinks\.in|gplus\.to|grabify\.link|gri\.ms|g\.ro\.lt|gurl\.es|hao\.jp|heg\.tc|hellotxt\.com|hex\.io|hfs\.rs|hiderefer\.com|hmm\.ph|hopclicks\.com|hop\.im|hotredirect\.com|hotshorturl\.com|href\.in|hsblinks\.com|ht\.ly|htxt\.it|hub\.am|hugeurl\.com|hulu\.com|hurl\.it|hurl\.me|hurl\.no|hurl\.ws|icanhaz\.com|icio\.us|idek\.net|ikr\.me|ilix\.in|inx\.lv|ir\.pe|irt\.me|iscool\.net|is\.gd|it2\.in|ito\.mx|its\.my|itsy\.it|ity\.im|ix\.lt|j2j\.de|jdem\.cz|jijr\.com|j\.mp|joinmy\.site|just\.as|k6\.kz|ketkp\.in|kisa\.ch|kissa\.be|kl\.am|klck\.me|kore\.us|korta\.nu|ko\.tc|kots\.nu|krunchd\.com|krz\.ch|ktzr\.us|kurl\.ng|kutt\.it|k\.vu|kxk\.me|l9k\.net|lat\.ms|l\.hh\.de|lc\.chat|lihi\.cc|liip\.to|liltext\.com|lin\.cr|lin\.io|link\.zip\.net|linkbee\.com|linkbun\.ch|linkee\.com|linkgap\.com|linkslice\.com|linktr\.ee|linxfix\.de|liteurl\.net|liurl\.cn|livesi\.de|lix\.in|lk\.ht|lnk\.by|lnk\.cm|lnk\.gd|lnks\.gd|lnk\.in|lnk\.ly|lnk\.sk|lnkurl\.com|lnnk\.in|ln-s\.net|ln-s\.ru|lol\.tc|loopt\.us|lost\.in|l\.pr|lru\.jp|lt\.tl|lurl\.no|lu\.to|m2\.tc|macte\.ch|mash\.to|mavrev\.com|memurl\.com|merky\.de|metamark\.net|migre\.me|min2\.me|minecräft\.com|minilien\.com|minilink\.org|miniurl\.com|minurl\.fr|mke\.me|mmo\.tc|moby\.to|moourl\.com|mrte\.ch|msg\.sg|murl\.kz|mv2\.me|myloc\.me|mysp\.in|myurl\.in|myurl\.si|nanoref\.com|nanourl\.se|nbc\.co|nblo\.gs|nbx\.ch|ncane\.com|ndurl\.com|ne1\.net|netnet\.me|netshortcut\.com|nig\.gr|ni\.to|nm\.ly|nn\.nf|notlong\.com|not\.my|n\.pr|nsfw\.in|nutshellurl\.com|nxy\.in|nyti\.ms|oboeyasui\.com|oc1\.us|offur\.com|ofl\.me|o\.ly|omf\.gd|om\.ly|omoikane\.net|on\.cnn\.com|onecent\.us|onforb\.es|on\.mktw\.net|onsaas\.info|ooqx\.com|orz\.se|ouo\.io|owl\.li|ow\.ly|o-x\.fr|oxyz\.info|p8g\.tw|packetlivesmatter\.club|packetlivesmatter\.online|parv\.us|paulding\.net|pduda\.mobi|peaurl\.com|pendek\.in|pep\.si|pic\.gd|piko\.me|ping\.fm|piurl\.com|pli\.gs|plumurl\.com|plurk\.com|plurl\.me|p\.ly|po\.st|poll\.fm|polr\.me|pop\.ly|poprl\.com|posted\.at|post\.ly|poweredbydialup\.club|poweredbydialup\.online|poweredbydialup\.org|poweredbysecurity\.online|poweredbysecurity\.org|pp\.gg|prettylinkpro\.com|profile\.to|pt2\.me|ptiturl\.com|pub\.vitrue\.com|puke\.it|pvp\.tc|pysper\.com|qik\.li|qlnk\.net|qoiob\.com|qqc\.co|qr\.ae|qr\.cx|qr\.net|qte\.me|quickurl\.co\.uk|qurl\.com|qurlyq\.com|qu\.tc|quu\.nu|qux\.in|qy\.fi|rb6\.me|rb\.gy|rde\.me|read\.bi|readthis\.ca|reallytinyurl\.com|redir\.ec|redirects\.ca|redirx\.com|relyt\.us|retwt\.me|reurl\.cc|rickroll\.it|r\.im|ri\.ms|rivva\.de|riz\.gd|rly\.cc|rnk\.me|rsmonkey\.com|rt\.nu|rubyurl\.com|ru\.ly|rurl\.org|rww\.tw|s2r\.co|s\.gnoss\.us|s\.id|s3nt\.com|s4c\.in|s7y\.us|safelinks\.ru|safe\.mn|sai\.ly|sameurl\.com|scrnch\.me|sdut\.us|sed\.cx|sfu\.ca|shadyurl\.com|shar\.es|shim\.net|shink\.de|shorl\.com|short\.cm|shortenurl\.com|shorten\.ws|shorterlink\.com|short\.ie|shortener\.cc|shortio\.com|shortlinks\.co\.uk|shortly\.nl|shortna\.me|shortn\.me|shortr\.me|short\.to|shorturl\.at|shorturl\.com|shortz\.me|shoturl\.us|shout\.to|show\.my|shredurl\.com|shrinkify\.com|shrinkr\.com|shrinkster\.com|shrinkurl\.us|shrten\.com|shrt\.fr|shrtl\.com|shrtn\.com|shrtnd\.com|shrt\.st|shrt\.ws|shrunkin\.com|shurl\.net|shw\.me|simurl\.com|simurl\.net|simurl\.org|simurl\.us|sitelutions\.com|siteo\.us|slate\.me|slidesha\.re|slki\.ru|sl\.ly|smallr\.com|smallr\.net|smarturl\.it|smfu\.in|smsh\.me|smurl\.com|smurl\.name|snadr\.it|sn\.im|snipie\.com|snip\.ly|snipr\.com|snipurl\.com|snkr\.me|snurl\.com|sn\.vc|song\.ly|soo\.gd|sp2\.ro|spedr\.com|spottyfly\.com|sqze\.it|srnk\.net|sro\.tc|srs\.li|starturl\.com|stickurl\.com|stopify\.co|stpmvt\.com|sturly\.com|su\.pr|surl\.co\.uk|surl\.hu|surl\.it|t2m\.io|ta\.gd|takemyfile\.com|tbd\.ly|t\.cn|tcrn\.ch|tek\.link|tgr\.me|tgr\.ph|th8\.us|thecow\.me|thrdl\.es|tighturl\.com|timesurl\.at|tiniuri\.com|tini\.us|tinyarro\.ws|tiny\.cc|tiny\.ie|tinylink\.com|tinylink\.in|tiny\.ly|tiny\.pl|tinypl\.us|tinysong\.com|tinytw\.it|tinyuri\.ca|tinyurl\.com|tl\.gd|t\.lh\.com|tllg\.net|t\.ly|tmi\.me|tncr\.ws|tnij\.org|tnw\.to|tny\.com|togoto\.us|to\.je|to\.ly|totc\.us|to\.vg|toysr\.us|tpm\.ly|traceurl\.com|trackurl\.it|tra\.kz|trcb\.me|trg\.li|trib\.al|trick\.ly|trii\.us|tr\.im|trim\.li|tr\.my|trumpink\.lt|trunc\.it|truncurl\.com|tsort\.us|tubeurl\.com|turo\.us|tw0\.us|tw1\.us|tw2\.us|tw5\.us|tw6\.us|tw8\.us|tw9\.us|twa\.lk|tweetburner\.com|tweetl\.com|tweez\.me|twhub\.com|twi\.gy|twip\.us|twirl\.at|twit\.ac|twitclicks\.com|twitterurl\.net|twitterurl\.org|twitthis\.com|twittu\.ms|twiturl\.de|twitvid\.com|twitzap\.com|twixar\.me|twlv\.net|twtr\.us|twurl\.cc|twurl\.nl|u\.bb|u76\.org|ub0\.cc|uiop\.me|ulimit\.com|ulu\.lu|u\.mavrev\.com|um\.lk|unfaker\.it|u\.nu|updating\.me|ur1\.ca|urizy\.com|url360\.me|url4\.click|url\.ag|urlao\.com|url\.az|urlbee\.com|urlborg\.com|urlbrief\.com|urlcorta\.es|url\.co\.uk|urlcover\.com|urlcut\.com|urlcutter\.com|urlenco\.de|urlg\.info|url\.go\.it|urlhawk\.com|url\.ie|url\.inc-x\.eu|urlin\.it|urli\.nl|urlkiss\.com|url\.lotpatrol\.com|urloo\.com|urlpire\.com|urls\.im|urltea\.com|urlu\.ms|urlvi\.b|urlvi\.be|urlx\.ie|ur\.ly|urlz\.at|urlzen\.com|urlzs\.com|usat\.ly|use\.my|uservoice\.com|ustre\.am|utfg\.sk|u\.to|v\.gd|v\.ht|vado\.it|vai\.la|vb\.ly|vdirect\.com|vgn\.am|viigo\.im|vi\.ly|virl\.com|viralurl\.com|vl\.am|vm\.lc|voizle\.com|vzturl\.com|vtc\.es|w0r\.me|w33\.us|w34\.us|w3t\.org|w55\.de|wa9\.la|wapo\.st|webalias\.com|welcome\.to|wh\.gov|widg\.me|virl\.ws|wipi\.es|wkrg\.com|woo\.ly|wow\.link|wp\.me|x\.co|xeeurl\.com|x\.hypem\.com|xil\.in|xlurl\.de|xr\.com|xrl\.in|xrl\.us|xrt\.me|x\.se|xurl\.es|xurl\.jp|x\.vu|xxs\.yt|xxsurl\.de|xzb\.cc|y\.ahoo\.it|yatuc\.com|ye\.pe|yep\.it|ye-s\.com|yfrog\.com|yhoo\.it|yiyd\.com|yko\.io|yourls\.org|yourtube\.site|youshouldclick\.us|youtubeshort\.pro|youtubeshort\.watch|yuarel\.com|yyv\.co|z0p\.de|zapt\.in|zi\.ma|zi\.me|zi\.mu|zi\.pe|zip\.li|zipmyurl\.com|zite\.to|zootit\.com|z\.pe|zud\.me|zurl\.ws|zzang\.kr|zz\.gd|ref\.vn|linq\.ist|zpr\.io)\/.+/i ) {
                $pubcount++;
            }
        }
    }
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_PUB_SHORTURL";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Public URL Shorteners found: $pubcount";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 1;
    }

    if ( $pubcount > $max ) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.17 * ($pubcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  check_priv_shorturls()

Default()=1

=over 5

=item  This is a test of URIs in the message body, looking for URL Shortener
services.  These services are grouped as Public (bit.ly, etc.) and Private 
(wpo.st, etc.).  When a match is found, the rule JR_PRIV_SHORTURL (in Auto
 mode) is set and the scoring of the rule is variable depending upon the count
 of Private URL Shorteners found above the defined limit, which is 1 by default.  

=back

=over 5

=item  In Tag mode, the rule  The rule, JR_PRIV_SHORTURL or <YOUR_RULENAME>
is set to a callout value of 0.01.  In Manual mode, the rule can be <NAMED>,
<DESCRIBED>, and <SCORED> in standard SpamAssassin fashion.

=back

=cut

sub check_priv_shorturls {
    my ( $self, $pms, $max ) = @_;
    local $uris = $pms->get_uri_detail_list();
    local $privcount = 0;
    local $set = 0;
    local $score = 0.01;
    while (my($uri, $info) = each %{$uris}) {
        next unless ($info->{domains});
        foreach ( keys %{ $info->{domains} } ) {
        # Private shorteners for company use/non-public: Tumblr, Wash Post,
        # France news, You Tube, Amazon, USA Gov, Bravo TV, LinkedIn, McAfee,
        # OReilly, Politico, Digg, Twitter, 4 Square, Daily Motion, Facebook,
        # Disqus, Deals Plus, Apache Org, SharePoint/Office URLs,
        # Business Journals, Huffington Post, The Onion, Microsoft, Goo.gl,
        # Constant Contact (conta.cc).
            if ( $uri =~  /https?:\/\/(.{1,15}\.)?(tumblr\.com|wpo\.st|url4\.eu|youtu\.be|amzn\.com|amzn\.to|go\.usa\.gov|bravo\.ly|lnkd\.in|mcaf\.ee|oreil\.ly|politi\.co|digg\.com|t\.co|4sq\.com|dai\.ly|fb\.me|disq\.us|dealspl\.us|s\.apache\.org|surl\.link|surl\.ms|officeurl\.com|bizj\.us|huff\.to|onion\.com|aka\.ms|goo\.gl|conta\.cc)\/.+/i ) {
                $privcount++;
            }
        }
    }
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_PRIV_SHORTURL";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Private URL Shorterners found: $privcount";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 1;
    }

    if ( $privcount > $max ) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.10 * ($privcount - $max + 1);
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  systeminfo()

Default()=7

=over 5

=item  Strut your stuff with thie Eval.  This tags every message with
an informative display or your system's capabilities.  This rule is scored at 
a callout level of 0.01 in all modes of operation.  You may change the rule 
name and description as desired.  

=back

=over 5

=item  There is a single Octal digit, that controls what (if any) 
information is presented in the report:

    _______________________________
    |         WEIGHT/VALUE        |
    |_____________________________|
    |    4    |    2    |    1    |  
    |_________|_________|_________|
    |  CHAOS  |   SA    |  PERL   |
    |_________|_________|_________|
    | 1 = ON  | 1 = ON  | 1 = ON  |
    | 0 = OFF | 0 = OFF | 0 = OFF |
    |_________|_________|_________|

    Examples: 0 = No version info displayed
              7 = All version info displayed
              4 = Only CHAOS version displayed
    
=back

=cut


sub systeminfo {
    my ( $self, $pms, $max ) = @_;
    local $from = $pms->get('From', undef);
    local $chaosver = "$VERSION";
    local $module = "Mail::SpamAssassin";
    local $errorCount = 0;
    local $saver = $module->VERSION;
    $saver =~ s/00/\./g;
    $saver =~ s/\.\./\./g;
    local $perlver = "$^V";
    local $score = 0.01;
    local $set = 0;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if( ! defined $max || ( $max !~ /\d+/ ) ) {
        $max = 7;
    }

    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "SYSTEM_INFO";
    }
        
    unless ( $from eq '' ) {
        local $description = $pms->{conf}->{descriptions}->{"$rulename"};
        if ( !defined $description ) {
            $description = " ";
        }
        if ( $max eq '0' ) {
            $describe .= "CHAOS: $description";
        } elsif ( $max eq '1' ) {
            $describe .= "PERL: $perlver - $description";
        } elsif ( $max eq '2' ) {
            $describe .= "SA: v$saver - $description";
        } elsif ( $max eq '3' ) {
            $describe .= "SA: v$saver PERL: $perlver - $description";
        } elsif ( $max eq '4' ) {
            $describe .= "CHAOS: v$chaosver - $description";
        } elsif ( $max eq '5' ) {
            $describe .= "CHAOS: v$chaosver PERL: $perlver - $description";
        } elsif ( $max eq '6' ) {
            $describe .= "CHAOS: v$chaosver SA: v$saver - $description";
        } elsif ( $max eq '7' ) {
            $describe .= "CHAOS: v$chaosver SA: v$saver PERL: $perlver - $description";
        } 

        $pms->{conf}->{descriptions}->{"$rulename"} = $describe;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  check_honorifics()

=over 5

=item  This tests the From Name field for honorifics (Mr./Mrs./Miss/Barrister,
etc) and if found, the rule JR_HONORIFICS, is set (Auto Mode).  This is a 
fixed score in Auto mode and a 0.01 callout value in Tag mode.  

=back

=over 5

=item In Manual mode, <YOUR_RULENAME> is scored  with whatever <YOUR_SCORE> 
and <YOUR_DESCRIBE>, in the standard  SpamAssassin fashion. 

=back

=cut

sub check_honorifics {
    my ( $self, $pms ) = @_;
    local $set = 0;
    local $count = 0;
    local $score = 0.01;
    local $firstword = "";
    local $restofname = "";
    local $from = $pms->get('From:name');
    if ( $from =~    /^\"?(Mr|Mrs|Ms|Miss|Sir|Engineer|Engr|Lord|Advocate|Evangelist|Lawyer|Manager|Barrister|Solicitor|Esquire|Attorney|Prof|Professor|Sgt|Capt|Diplomat|Engr|Sr)(\.|\s|\,)/gi ) {
        $count = 1;
        ($firstword,$restofname) = split(/[\s\.\,]/, $from);  
    # DE
    } elsif ( $from =~   /^\"?(Herr|Frau?|Fraulein|Bruder|Schwester)(\.|\s|\,)/gi ) {
        $count = 1;
        ($firstword,$restofname) = split(/[\s\.\,]/, $from);  
    # FR
    } elsif ( $from =~   /^\"?(Monsieur|Mademoiselle|Mms|Madam|Mme\.|Avocat|Diplomate)(\.|\s|\,)/gi ) {
        $count = 1;
        ($firstword,$restofname) = split(/[\s\.\,]/, $from);  
    # SE
    } elsif ( $from =~   /^\"?(Fru|Fröken|Du|Herrn|Herre|Advokat|Statsman|Bror)(\.|\s|\,)/gi ) {
        $count = 1;
        ($firstword,$restofname) = split(/[\s\.\,]/, $from);  
    # ES
    } elsif ( $from =~   /^\"?(señor|caballero|señora|señorita|licenciado|doña|ud|tú|Hermano|Sor|Hermano|Abogado)/gi ) {
        $count = 1;
        ($firstword,$restofname) = split(/[\s\.\,]/, $from);  
    }
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_HONORIFICS";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Honorifics in From Name: $firstword";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
     
    if ($count >= 1) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.33;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  from_in_subject()

=over 5

=item  This tests looks for the presence of the From Name field in the Subject.
If so, rule JR_SUBJ_HAS_FROM_NAME is set in Auto Mode and scored at a fixed
level.  In Tag mode, JR_SUBJ_HAS_FROM_NAME or <YOUR_RULENAME> is scored at a
callout value of 0.01.  

=back

=over 5

=item  In Manual mode, JR_SUBJ_HAS_FROM_NAME or <YOUR_RULENAME> is scored and
described in the standard SA fasion.

=back

=cut

sub from_in_subject {
    my ( $self, $pms ) = @_;
    local $set = 0;
    local $count = 0;
    local $score = 0.01;
    local $subject = $pms->get('Subject');
    local $from = $pms->get('From:name');
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_SUBJ_HAS_FROM_NAME";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Subject contains the From Name: $from";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    # Check for NO From Name, otherwise it will match.
    if (( $from ne "" ) &&  ( $subject =~ /^((My\sname\sis|From|Fra|Hello|It\'s\sme|Hola)?\s)?($from)$/gi )) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.55;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  first_name_basis()

=over 5

=item  This tests the From Name field for the use of a single First Name.
The match includes some first name variants, like "Mr. Jared", "Jared at 
home", or First Name and Last Initial.  In Auto mode, the rule 
JR_FRM_FRSTNAME is scored with a fixed score.

=back

=over 5

=item  In Tag mode, JR_FRM_FRSTNAME or <YOUR_RULENAME> is set and scored
with a callout value of 0.01.

=back

=over 5

=item  In Manual mode, you many name this rule whatever you like and
<YOUR_RULENAME> is scored and described in standard SA fashion.

=back

=cut

sub first_name_basis {
    my ( $self, $pms ) = @_;
    local $set = 0;
    local $count = 0;
    local $score = 0.01;
    local $fname1 = "";
    local $fname2 = "";
    local $fname3 = "";
    local $fname4 = "";
    local $fname_plus = "";
    local $from = $pms->get('From:name');
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FRM_1STNAME";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: From Nme has First Name Only: $from";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
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
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.3;
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  from_no_vowels()

=over 5

=item  This tests the From Name for gibberish.  If there are space-separated
 word characters but no vowels present, the rule is matched.  The rule 
 JR_FROM_NO_VOWEL is scored at a fixed rate in Auto mode and scored with a
 callout value of 0.01 in Tag mode. 

=back

=over 5

=item  In Manual mode, JR_FROM_NO_VOWEL or <YOUR_RULENAME> is scored and
described in the standard SA fasion.

=back

=cut

sub from_no_vowels {
    my ( $self, $pms ) = @_;
    local $set = 0;
    local $count = 0;
    local $score = 0.01;
    local $from = $pms->get('From:name');
    local $size = length($from);
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_FROM_NO_VOWEL";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: From Name has words, no vowels";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if (( $size >= 7 ) && ( $from =~ /\w\s+\w/ )) {
        if ( $from =~ /(\xC3\x80|\xC3\x81|\xC3\x82|\xC3\x83|\xC3\x84|\xC3\x85|\xC3\x88|\xC3\x89|\xC3\x8A|\xC3\x8B|\xC3\x8C|\xC3\x8D|\xC3\x8E|\xC3\x8F|\xC3\x92|\xC3\x93|\xC3\x94|\xC3\x95|\xC3\x96|\xC3\x98|\xC3\x99|\xC3\x9A|\xC3\x9B|\xC3\x9C|\xC3\x9D|\xC3\xA0|\xC3\xA1|\xC3\xA2|\xC3\xA3|\xC3\xA4|\xC3\xA5|\xC3\xA8|\xC3\xA9|\xC3\xAA|\xC3\xAB|\xC3\xAC|\xC3\xAD|\xC3\xAE|\xC3\xAF|\xC3\xB2|\xC3\xB3|\xC3\xB4|\xC3\xB5|\xC3\xB6|\xC3\xB8|\xC3\xB9|\xC3\xBA|\xC3\xBB|\xC3\xBC|\xC3\xBD|\xC3\xBF|\xC4\x80|\xC4\x81|\xC4\x82|\xC4\x83|\xC4\x84|\xC4\x85|\xC4\x92|\xC4\x93|\xC4\x94|\xC4\x95|\xC4\x96|\xC4\x97|\xC4\x98|\xC4\x99|\xC4\x9A|\xC4\x9B|\xC4\xA8|\xC4\xA9|\xC4\xAA|\xC4\xAB|\xC4\xAC|\xC4\xAD|\xC4\xAE|\xC4\xAF|\xC4\xB0|\xC4\xB1|\xC5\x8C|\xC5\x8D|\xC5\x8E|\xC5\x8F|\xC5\x90|\xC5\x91|\xC5\xA8|\xC5\xA9|\xC5\xAA|\xC5\xAB|\xC5\xAC|\xC5\xAD|\xC5\xAE|\xC5\xAF|\xC5\xB0|\xC5\xB1|\xC5\xB2|\xC5\xB3|\xC5\xB6|\xC5\xB7|\xC5\xB8)/gi ) {
        $count++;
        }
        if ( $from =~ /(A|E|I|O|U|Y)/gi ) {
        $count++;
        }
        if ( $count == 0 ) {
            if ( $mode eq "AutoISP" ) { 
                $score = $pms->{conf}->{chaos_tag} * 0.55;
            }
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
        $   pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }

return 0;
}

=head2  check_admin_fraud()

=over 5

=item  This is a Subject header test for Admin Fraud [Account Disabled, Over
Quota, etc.] messages.  Also included are Subject header tests for the old 
SOBIG and SOBER worms.  

=back

=over 5

=item  In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule, 
describe it, and score it in standard SA fashion.

=back

=cut

sub check_admin_fraud {
    my ( $self, $pms ) = @_;
    local $subject = $pms->get('Subject');
    local $set = 0;
    local $score = 0.01;
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
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_ADMIN_FRAUD";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Admin Fraud/Worm/Extortion detected";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    if ($count >= 1) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head2  check_admin_fraud_body()

=over 5

=item  This is a Body test that looks for Admin Fraud [Account Disabled, Quota 
Exceeded, etc.] messages.  This test is more expensive than standard Body 
rules which are pre-compiled with RE2C.  It's not bad, but still something to 
consider.

=back

=over 5

=item  In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule, 
describe it, and score it in standard SA fashion.

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
        
    local $set = 0;
    local $score = 0.01;
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_ADMIN_BODY";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    if ((!defined($description)) || ($mode ne "Manual")) {
        $description = "CHAOS: Admin Fraud messages in body: $count";
    }
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }

    if ( $count != 0 ) {
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}

=head2  check_email_greets()

=over 5

=item  This is a Body test that looks for common phrases and greetings using
the User-Part of the E-Mail address.  If there is a match, rule 
"JR_BODY_TO_ADDR" is set.  Example: "Hi username"...

=back

=over 5

=item  In Tag mode the rulename can be whatever you like, however the score is
fixed at a callout level of 0.01.  In Manual mode, you may name the rule, 
describe it, and score it in standard SA fashion.

=back

=cut

sub check_email_greets {
    my ( $self, $pms ) = @_;
    local $set = 0;
    local $count = 0;
    local $score = 0.01;
    local $toaddr = $pms->get('To:addr', "");
    # local $preview = $pms->get_decoded_stripped_body_text_array();
    local $preview = $pms->get_content_preview();
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = $pms->get_current_eval_rule_name();
    if (($rulename eq '') || ($mode eq "AutoISP")) {
        $rulename = "JR_BODY_TO_ADDR";
    }
    local $description = $pms->{conf}->{descriptions}->{"$rulename"};
    local $score = $pms->{conf}->{scoreset}->[$set]->{"$rulename"};
    if ((!defined($score)) || ($mode ne "Manual")) {
        $score = 0.01;
    }
    
    if ($toaddr ne "") {
        chomp $toaddr;
        local($usrpart,$domain) = split /\@/, $toaddr;
        if ((!defined($description)) || ($mode ne "Manual")) {
            $description = "CHAOS: The body contains the Email userpart in a greeting: $usrpart";
        }
        if ( $mode eq "AutoISP" ) { 
            $score = $pms->{conf}->{chaos_tag} * 0.25;
        }
        if ( $usrpart ne "" ) {
            if ( $preview =~ /^\s*([Hh]ello|(hi\s)?[Dd]ear|[[Gg]ood\s[Dd]ay|[Hh]i|[Hh]e[yj]|[zZ]dravo)\s+$usrpart[.,:;!]/g ) {
                $count++;           
            } elsif ( $preview =~ /^\s*([Hh]all?o|[Gg]uten\s[Tt]ag|[Bb]onjour|[Ss]aluti?|Ola)\s+$usrpart[.,:;!]/g ) {
                $count++;
            } elsif ( $preview =~ /^\s*([Cc]oucou|[H]ej|[Hh]ejsan|God\s[Dd]ag|[Aa]hoj|[Hh]elló|[Ss]zia)\s+$usrpart[.,:;!]/g ) {
                $count++;
            } elsif ( $preview =~ /^\s*([H]hola|[Cc]iao|[Ss]alve|[Bb]uongiorno|[Bb]om\s[Dd]ia)\s+$usrpart[.,:;!]/g ) {
                $count++;
            } elsif ( $preview =~ /^\s*([Dd]obrý\s[Dd]en|[Qq]uerid[oa]|[Cc]h[eè]re?|[Pp]ozdravy|[Hh]älsningar)\s+$usrpart[.,:;!]/g ) {
                $count++;
            } elsif ( $preview =~ /^\s*([Tt]schüss|[Pp]ozdrowienia|[Cc]zesc|[Dd]zien\s[Dd]obry|[Žž]ivjo)\s+$usrpart[.,:;!]/g ) {
                $count++;
            }
        }
        if ( $count >= 1 ) {
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    # $description = "CHAOS: $usrpart $domain";
    # $pms->{conf}->{descriptions}->{"$rulename"} = $description;
    # $pms->got_hit("$rulename", "", score => $score);
    # $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
return 0;
}


=head2  mailer_check()

=over 5

=item  Provides a lot of information about the sending system and the E-Mail
 format.  Rulenames herein are immutable.  In all modes of operation, scores
 are fixed at a callout level of 0.01 unless marked with an Asterisk.  Those
 rules are scored in Auto mode only. 

=back

=over 5

=item  B<X-Header Detections> 
 
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
    JR_FISHBOWL         JR_ICEWARP              JR_KLAVIYO *
	JR_NOVELL_XMAILER * JR_BAD_ATMAIL *
        
=back

=over 5

=item  B<PHP Script Detections>


This checks for the presence of headers that indicate that the message was sent by a bad or exploited PHP script.  A single immutable rulename with a callout score is returned, unless in Auto mode:

    JR_PHP_SCRIPT
 
=back

=over 5

=item  B<UTF-8 Checks>

=back

=over 5

=item  This checks the FROM, TO, REPLY-TO, and SUBJECT headers for Unicode 
 Transformation Format headers, UTF-8.  Thie rulename is immutable and is
 scored with a callout value of 0.01 in all modes.  The rulenames returned
 by this Eval describe either Quoted-Printable or Base-64 encodings:
 
    JR_SUBJ_UTF8_QP     JR_SUBJ_UTF8_B64
    JR_FROM_UTF8_QP     JR_FROM_UTF8_B64
    JR_TO_UTF8_QP       JR_TO_UTF8_B64
    JR_REPLY_UTF8_QP    JR_REPLY_UTF8_B64

=back

=over 5

=item B<User-Agent Checks>

=back

=over 5

=item  This checks for the presence of a User-Agent header.  All such rules are scored at callout values only except those marked with an Asterisk*.  These are assigned a score in Auto mode.
 
    JR_ROUNDCUBE        JR_HORDE
    JR_THUNDERBIRD      JR_UNK_USR_AGENT
    JR_ALPINE           JR_MAC_OUTLOOK
    JR_MUTT             JR_EMCLIENT
    JR_ANDROID          JR_SQUIRRELMAIL
    JR_DADDYMAIL        JR_KMAIL
    JR_REDCAPPI         JR_TRAYSOFT
    JR_JINO *           JR_SEAMONKEY
    JR_KMAIL

=back

=over 5

=item B<Miscellaneous Checks>

=back

=over 5

=item  Various checks for headers that indicate a bad message.  A variety of Mailchimp sanity checks are performed.  JR_EXCHANGE is a callout rule set when Microsoft Exchange Server headers are detected.  Many Microsoft Exchange header sanity checks are also performed.  JR_DUP_HDRS hits whenever multiple IDENTICAL header lines appear in a message.  There are also tests, JR_MULTI_HDRS, for headers that should never appear more than once.  There are also checks for headers that shouldn't appear in the presence of other headers.   

    JR_BOGUS_HEADERS *      JR_BAD_CHIMP *
    JR_X_BEENTHERE *        JR_X_SENTBY *
    JR_EXCHANGE             JR_EXCHANGE_AUTH *
    JR_EXCH_BAD_AUTH *      JR_EXCH_ATTACH *
    JR_EXCHANGE_TYPE *      JR_X_UNVERIFIED *
    JR_DUP_HDRS *           JR_MULTI_HDRS *
    JR_PRI_MULTI *          JR_BULK *
    JR_SGRID_FWD *          JR_SGRID_DIRECT *

=back

=over 5

=item  All rules are callout values unless marked with an asterisk (*).  These are scored at various fixed rates when in Auto mode. 

=back

=over 5

=item  JR_SGRID_FWD and JR_SGRID_DIRECT reflect the presence of SendGrid mailer information.  If SendGrid headers are wrapped up in another container, like a References header, JR_SGRID_FWD is set.  In Auto mode, this is scored lower than the DIRECT rule which is set for direct emails from SendGrid, SendGrid partner companies, or the SendGrid API.

=back

=cut

sub mailer_check {
    my ( $self, $pms ) = @_;;
    local $mailgun1 = $pms->get("X-Mailgun-Sid", undef);
    local $mailgun2 = $pms->get("X-Mailgun-Sending-Ip", undef);
    local $xmail = $pms->get('X-Mailer');
    local $allheaders = $pms->get('ALL');
    local $zohocnt = 0;
    local $set = 0;
    local $score = 0.01;
    local $count = 0;
    local $mailer = "";
    local $mode = $pms->{conf}->{chaos_mode};
    local $rulename = "JR_MAILER";
    local $description = "CHAOS: ";
    
    if ( $xmail =~  /(The\sBat\!\s(\(v3\.71\.04\)\sHome|\(v3\.0\.1\.33\)\sProfessional|\(v2\.4.5\)\sPersonal|\(v3\.71\.14\)\sProfessional|\(v2\.4.5\)\sBusiness|\(v3\.71\.01\)\sHome|\(v3\.0\.1\sRC7\)\sUNREG\s\/\sE0XUKJWV2Y|\(v3\.60\.07\)\sProfessional|\(v3\.5\.25\)\sHome|\(v3\.62\.14\)\sEducational|\(v2\.04\.7\)\sBusiness\(v2\.00\.7\)\sPersonal|\(v2\.12\.00\)|\(v1\.51\)|\(v1\.60c\)|\(v3\.51\.4.5\)|\(v2\.00\.1\)|\(v1\.55\.3\)|\(v3\.62\.03\)|\(v2\.00\.8\)|\(v4\.54\.6\)|\(v2\.00\)\sEducational|\(v3\.65\.03\)\sHome|\(v2\.00\.7\)\sPersonal|\(v2\.12\.00\)\sBusiness|\(v2\.00\.6\)\sEducational|\(v2\.00\.6\)\sPersonal|\(v3\.5\.25\)\sHome|\(v3\.71\.01\)\sHome|\(3\.72\.01\)\sProfessional|\(v3\.80\.06\)\sEducational|\(v2\.4.5\.01\)\sEducational|\(v2\.00\.8\)\sBusiness|\(v2\.00\.5\)\sPersonal|\(v2\.12\.00\)\sPersonal|\(v3\.0\.1\.33\)\sProfessional|\(v2\.00\.1\)\sPersonal|\(v2\.00\.18\)\sEducational|\(v2\.00\.0\)\sPersonal|\(v2\.00\.9\)\sPersonal|\(v2\.00\.4\)\sPersonal|\(v2\.00\.2\)\sPersonal|\(v3\.80\.06\)\sProfessional|\(v3\.5\.30\)\sEducational|\(v3\.5\)\sHome|\(v3\.0\.1\.33\)|\(v3\.5\)\sProfessional|\(v3\.71\.14\)\sUNREG\s\/\sCD5BF9353B3B7091|\(v3\.0\)\sHome|\(v3\.81\.14\sBeta\)\sHome|\(v3\.62\.14\)\sEducational|\(v2\.00\.6\)\sPersonal|\(v2\.00\.6\)\sEducational|\(v3\.5\.25\)\sHome|\(v3\.80\.06\)\sEducational|\(v3\.71\.01\)\sHome|\(v3\.81\.14\sBeta\)\sHome))/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILER_BAT";
        $mailer = "Bad Bat Version";
    } elsif ( $xmail =~ /(The\sBat\!\s(\(v3\.81\.14\sBeta\)\sEducational|\(v2\.00\.6\)\sBusiness|\(v3\.80\.06\)\sHome|\(v2\.01\)\sPersonal|\(v2\.00\.3\)\sBusiness|\(v3\.81\.14\sBeta\)\sProfessional|\(v2\.4.5\.03\)\sEducational|\(v3\.51\)\sEducational|\(v3\.71\.01\)\sEducational|\(v3\.71\.14\)\sEducational|\(v2\.04\.7\)\sPersonal|\(v3\.0\.0\.15\)\sHome|\(v3\.5\.25\)\sHome|\(v4\.0\.24\)|\(v3\.65\.03\)\sHome|\(v3\.0\.0\.15\)\sProfessional|\(v2\.04\.7\)\sEducational|\(v2\.00\.9\)\sEducational|\(v3\.62\.14\)\sProfessional|\(v3\.81\.14\sBeta\)\sHome|\(v3\.62\.14\)\sUNREG\s\/\sCD5BF9353B3B7091|\(v2\.01\)\sBusiness|\(v3\.51\)\sHome|\(v2\.4.5\.03\)\sBusiness|\(v2\.00\.9\)\sPersonal|\(v2\.01\)|\(v3\.71\.01\)\sHome|\(v3\.71\.14\)\sProfessional|\(v3\.0\.1\.33\)\sEducational|\(v2\.00\.7\)\sEducational|\(v3\.5\)\sHome|\(v3\.0\.0\.15\)\sEducational|\(v2\.11\)\sPersonal|\(v3\.0\)\sProfessional|\(v2\.00\.18\)\sBusiness|\(v3\.80\.03\)\sHome|\(v2\.00\.0\)\sEducational|\(v2\.00\.7\)\sEducational|\(v2\.00\.3\)\sPersonal|\(v2\.00\.9\)\sBusiness|\(v2\.00\.0\)\sEducational\(v3\.71\.04\)\sEducational|\(v2\.00\.3\)\sEducational|\(v3\.0\.1\.33\)\sHome|\(v3\.0\.2\.2\sRush\)\sUNREG\s\/\sE0XUKJWV2Y|\(v3\.0\.1\.33\)|\(v2\.00\.4\)|\(v2\.00\.2\)|\(v2\.00\.7\)|\(v2\.00\.3\)|\(v2\.00\.6\)|\(v2\.00\.0\)|\(v3\.5\.30\)|\(v3\.6\.07\)|\(v2\.4.5\.03\)\sBusiness|\(v3\.80\.03\)\sProfessional|\(v3\.71\.01\)\sProfessional))/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILER_BAT";
        $mailer = "Bad Bat Version";
    } elsif ( $xmail =~ /PHPMailer\s5\.[0-1]\.[0-9]{1,2}/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILER_PHP";
        $mailer = "Obsolete PHP Mailer";
    } elsif ( $xmail =~ /PHPMailer\s5\.2\.[0-9]{1,2}/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.35 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILER_PHP";
        $mailer = "Old PHP Mailer";
    } elsif (( $xmail =~ /PHPMailer\s/g ) && ( $xmail !~ /\[version\s\d\.\d+\]/g )) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILER_PHP";
        $mailer = "Forged PHP Mailer";
    } elsif ( $xmail =~ /Chilkat\sSoftware/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.21 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_CHILKAT";
        $mailer = "Chilkat";
    }  elsif    ( $xmail =~ /MailKing/gi ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILKING";
        $mailer = "Mail King";
    } elsif ( $xmail =~ /Sendinblue/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.35 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_SENDBLUE";
        $mailer = "Send In Blue";
    } elsif ( $xmail =~ /Ihffxjaaop\s\d/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Ihffxjaaop (JP)";
    } elsif ( $xmail =~ /xmail\sx3\ssupra/gi ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";       
        $mailer = "Supra Mailer";
    } elsif ( $xmail =~ /Avalanche/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Avalanche";
    } elsif ( $xmail =~ /Crescent\sInternet/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Crescent Tool";
    } elsif ( $xmail =~ /DiffondiCool/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "DiffondiCool";
    } elsif ( $xmail =~ /E\-Mail\sDelivery\sAgent/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Delivery Agent";
    } elsif ( $xmail =~ /Emailer\sPlatinum/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Platinum";
    } elsif ( $xmail =~ /Entity/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Entity";
    } elsif ( $xmail =~ /Extractor/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Extractor Pro";
    } elsif ( $xmail =~ /Floodgate/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Floodgate";
    } elsif ( $xmail =~ /GOTO\sSoftware/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "GOTO Software";
    } elsif ( $xmail =~ /MailWorkz/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "MailWorkz";
    } elsif ( $xmail =~ /MassE\-Mail/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Mass E-Mail";
    } elsif ( $xmail =~ /MaxBulk\.Mailer/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "MaxBulk";
    } elsif ( $xmail =~ /News\sBreaker/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "News Breaker Pro";
	} elsif ( $xmail =~ /\x3F\x3F[0-9]\x3F[0-9.]{6,8}\x3F\x3F/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Unknown UTF-8 Mailer";
    } elsif ( $xmail =~ /SmartMailer/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.21 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "Smart Mailer";
    } elsif ( $xmail =~ /StormPort/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.21 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "StormPort";
    } elsif ( $xmail =~ /SuperMail\-2/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.21 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_GEN_XMAILER";
        $mailer = "SuperMail";
	} elsif ( $xmail =~ /Novell[\s_]GroupWise/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.21 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_NOVELL_XMAILER";
        $mailer = "Novell GroupWise Agent";
    } elsif ( $xmail =~ /ATL[\s_]CSmtp[\s_]Class[\s_]Mailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ATL_MAILER";
        $mailer = "ATL SMTP Classes";
    } elsif ( $xmail =~ /Microsoft[\s_]Office[\s_]Outlook(\,\sBuild)?[\s_]11/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OUTLOOK_2003";
        $mailer = "Microsoft Outlook 2003";
    } elsif ( $xmail =~ /Microsoft[\s_]Office[\s_]Outlook[\s_]12/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OUTLOOK_2007";
        $mailer = "Microsoft Outlook 2007";
    } elsif ( $xmail =~ /Microsoft[\s_]Outlook[\s_]14/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OUTLOOK_2010";
        $mailer = "Microsoft Outlook 2010";
    } elsif ( $xmail =~ /Microsoft[\s_]Outlook[\s_]15/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OUTLOOK_2013";
        $mailer = "Microsoft Outlook 2013";
    } elsif ( $xmail =~ /Microsoft[\s_]Outlook[\s_]16/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OUTLOOK_2016";
        $mailer = "Microsoft Outlook 2016";
    } elsif ( $xmail =~ /MailChimp\sMailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MAILCHIMP";
        $mailer = "Mail Chimp";
    } elsif ( $xmail =~ /Microsoft[\s_]Outlook[\s_]Express/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.35 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_OUTLOOK_EXPRESS";
        $mailer = "Outlook Express";
    } elsif ( $xmail =~ /(Encumbered|Achromatous|\xC3\xA2\xC5\x93\xE2\x80\x93\xC3\xAF\xC2\xB8\xC2\x8F)/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.65 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_VIRUS_MAILERS";
        $mailer = "General Virus Mailer: $xmail";
    } elsif ( $xmail =~ /Roving[\s_]Constant[\s_]Contact/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_CCONTACT";
        $mailer = "Constant Contact List Manager";
    } elsif ( $xmail =~ /sailthru\.com/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_SAILTHRU";
        $mailer = "Sailthru.com Media Mailer";
    } elsif ( $xmail =~ /ZuckMail/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_FACEBOOK";
        $mailer = "Facebook Mailer";
    } elsif ( $xmail =~ /Zoho[\s_]Campaigns/g ) {
        $score = 0.01;
        $zohocnt++;
        $count++;
        $rulename = "JR_ZOHO";
        $mailer = "Zoho Mailer";
    } elsif ( $xmail =~ /CheetahMailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_CHEETAH";
        $mailer = "Cheetah Mailer";
    } elsif ( $xmail =~ /XyzMailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_XYZMAILER";
        $mailer = "XyzMailer Python to PHP Mail";
    } elsif ( $xmail =~ /Blue[\s_]Streak/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_BLUESTREAK";
        $mailer = "Blue Streak Email";
    } elsif ( $xmail =~ /nlserver\,[\s_]Build/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_NEOLANE";
        $mailer = "Neolane MARCOM System";
    } elsif ( $xmail =~ /Oracle[\s_]Communications[\s_]Messenger[\s_]Express/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ORACLE_XPRESS";
        $mailer = "Oracle Communications Messenger Express";
    } elsif ( $xmail =~ /eSputnik\.com[\s_]Mailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ESPUTNIK";
        $mailer = "eSputnik.com Mail";
    } elsif ( $xmail =~ /^Zimbra[\s\/_]/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ZIMBRA";
        $mailer = "ZIMBRA Collaboration Server";
    } elsif ( $xmail =~ /BM23[\s\/_]Mail/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.15 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_BRONTO";
        $mailer = "Bronto Mail Services";
    } elsif ( $xmail =~ /MIME::Lite/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MIMELITE";
        $mailer = "PERL MIME::Lite attachment processor";
    } elsif ( $xmail =~ /msgsend/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MSGSEND";
        $mailer = "msgsend - JavaMail processor";
    } elsif ( $xmail =~ /ColdFusion[\s\/_]/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_COLDFUSION";
        $mailer = "ColdFusion Application Server";
    } elsif ( $xmail =~ /HMail[\s_]Webmail[\s_]_Server/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_163_HMAIL";
        $mailer = "163.com's Webmail Service";
    } elsif ( $xmail =~ /Create[\s_]_Send/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_CREATESEND";
        $mailer = "CreateSend Newsletter mailer";
    } elsif ( $xmail =~ /WhatCounts/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_WHATCOUNTS";
        $mailer = "Whatcounts.com Customer Engagement";
    } elsif ( $xmail =~ /MailSender[\s_]\[/g ) {
        $score = 0.01;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.12 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_MAILSENDER";
        $mailer = "Spring.io JavaMailSender package";
    } elsif ( $xmail =~ /^Sendy[\s_]\(https:\/\/sendy\.co\)/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_SENDY";
        $mailer = "Sendy.com Newsletter Mailer";
    } elsif ( $xmail =~ /Atmail$/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ATMAIL";
        $mailer = "Atmail.com Customer engagement";
	} elsif ( $xmail =~ /AtMail\sPHP\s5/g ) {
        $score = 0.01;
		if ( $mode eq "AutoISP" ) { 
            $score = 0.22 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_BAD_ATMAIL";
        $mailer = "Bad AtMail Mailer";
    } elsif ( $xmail =~ /Microsoft_CDO_for_Windows/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MS_CDO";
        $mailer = "Microsoft Collaboration Data Objects";
    } elsif ( $xmail =~ /aspNetEmail/g ) {
        $score = 0.01;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.09 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_ASPNET";
        $mailer = "Microsoft Webmail Interface";
    } elsif ( $xmail =~ /placewisemail\.com/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_PLACEWISE";
        $mailer = "Retail/Mall engagement platform";
    } elsif ( $xmail =~ /MarshallSoft_SMTP/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MARSHALL";
        $mailer = "MarshallSoft SMTP EMail Engine";
    } elsif ( $xmail =~ /MailBee\.NET/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MAILBEE";
        $mailer = "Afterlogic .NET components for Email";
    } elsif ( $xmail =~ /ECP01|ECP02/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ECP_MAIL";
        $mailer = "eCampaign Pro Email";
    } elsif ( $xmail =~ /PHP7\.[0-9]/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_PHP7_MAIL";
        $mailer = "Standard PHP 7.x Mail";
    } elsif ( $xmail =~ /\baolwebmail\b/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_AOL_WEBMAIL";
        $mailer = "AOL WebMmail/Safari headers detected";
    } elsif ( $xmail =~ /\bIBM[\s_]Traveler\b/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_IBM_TRAVELER";
        $mailer = "IBM Domino/Notes Traveler mail client detected";
    } elsif ( $xmail =~ /KeyesMail/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_KEYS_MAIL";
        $mailer = "IBM/Computer-Keyes Email client detected";
    } elsif ( $xmail =~ /Nodemailer[\s_]/g ) {
        $score = 0.01;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.12 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_NODEMAILER";
        $mailer = "Java (Node.js) Emailer";
    } elsif ( $xmail =~ /RM[\s_]Mailer[\s_]\(v.*\)/g ) {
        $score = 0.01;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.12 * $pms->{conf}->{chaos_tag};
        }
        $count++;
        $rulename = "JR_REACHMAIL";
        $mailer = "ReachMail E-Mail Marketing Service";
    } elsif ( $xmail =~ /SA[\s_]NetWeaver/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_SAP_WEAVER";
        $mailer = "SAP Integration Software Stack";
    } elsif ( $xmail =~ /Fishbowl[\s_][0-9\.]+/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_FB_MTA";
        $mailer = "fbmta.com Fishbowl Customer Loyalty Mailer";
    } elsif ( $xmail =~ /dmDroid/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_DMDROID";
        $mailer = "dotmailer.com dmDROID Mailer";
    } elsif ( $xmail =~ /MarshallSoft[\s_]SMTP\/POP3/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_MARSHALL";
        $mailer = "MarshalSoft Visual dBase Email Components";
    } elsif ( $xmail =~ /Open-Xchange[\s_]Mailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_OPEN_XCHANGE";
        $mailer = "Open-Xchange.com OX Email Platform";
    } elsif ( $xmail =~ /Fox[Mm]ail[\s_]\d/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_FOXMAIL";
        $mailer = "Tencent's Foxmail for Windows (China)";
    } elsif ( $xmail =~ /Claws[\s_]Mail/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_CLAWS_MAIL";
        $mailer = "Claws Mail Windows/Unix E-Mail client";
    } elsif ( $xmail =~ /Fishbowl[\s_]/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_FISHBOWL";
        $mailer = "Using the Fishbowl MTA (fbmta)";
    } elsif ( $xmail =~ /IceWarp[\s_]Mailer/g ) {
        $score = 0.01;
        $count++;
        $rulename = "JR_ICEWARP";
        $mailer = "IceWarp Business Collaboration Server";
    } 

    if ($count > 0) {
        $description .= "$mailer";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
    }
    
    $score = 0.01;
    $description = "CHAOS: ";
    if ( $allheaders =~ /cp20\.com/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $rulename = "JR_CAMPAIGN_PRO";
        $mailer = "CampaignerPro";
        $description .= "Mailer is: $mailer";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    } elsif ( $allheaders =~ /\.maropost\.com/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.16 * $pms->{conf}->{chaos_tag};
        }
        $rulename = "JR_MAROPOST";
        $mailer = "Maropost";
        $description .= "Mailer is: $mailer";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    $score = 0.01;
    $description = "CHAOS: ";
    if (( defined $mailgun1 ) || ( defined $mailgun2 )) {
        $rulename = "JR_MAILGUN";
        $description .= "Mail sent with Mailgun";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "HEADER: ", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    ### PHP Script Detections ###
    local $pmail = $pms->get('X-PHP-Originating-Script');
    $set = 0;
    $score = 0.01;
    $count = 0;
    $rulename = "JR_PHP_SCRIPT";
    $description = "CHAOS: ";
    
    if ( $pmail =~  /[0-9]{2,8}:([A-Z]{7}\.php|[0-9]{1,4}\.php)/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:scomxqvjfkpmgpjc\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:st\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /eval\(\)\'d\scode/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /zebi\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /(1{2,5}|2{2,5}|3{2,5}|4{2,5}|5{2,5}|6{2,5}|7{2,5}|8{2,5}|9{2,5}|0{2,5})\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /sendEmail/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /MailSend\.php/g ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.5 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:Sendmail\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = -0.2 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:(aa1|inboxnew|1a|ok|object)\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:ECI_Offset_2009\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = -0.2 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:(alexus|alexus\-smtp|alexusMailer_v2\.0)\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:(MatrixInboxV16|leaf|gzip64|MailE)\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $pmail =~ /[0-9]{2,8}:(rcmail|rcube)\.php/g ) {
        $count++;
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }
    }
    

    if ($count > 0) {
        $description .= "Sent from a PHP Script - $pmail";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    ### APPLE Checks ###
    local $mheader = $pms->get('Content-Type');
    local $apple = () = $mheader =~ /boundary\=.*Apple\-Mail\-.*/;
    $score = 0.01;
    $count = 0;
    $set = 0;
    $rulename = "JR_APPLE_DEVICE";
    $description = "CHAOS: ";
    if ( $xmail =~  /iPhone[\s_]Mail/g ) {
        $description .= "iPhone Device Detected";
        $count++;
    } elsif ( $xmail =~ /iPad[\s_]Mail/g ) {
        $description .= "iPad Device Detected";
        $count++;
    } elsif ( $xmail =~ /Apple[\s_]Mail/g ) {
        $description .= "Apple Detected";
        $count++;
    } elsif ( $apple >= 1 ) {
        $description .= "Apple MIME Signature Detected";
        $count++;
    }
    local $appleuagt = $pms->get("User-Agent", undef);
    if ( defined $appleuagt ) {
        if ( $appleuagt =~ /iPhoneOS\//g ) {
            $description .= "iPhone Device Detected";
            $count++;
        } elsif ( $appleuagt =~ /iPadOS\//g ) {
            $description .= "iPad Device Detected";
            $count++;
        }
    }
    if ( $count >= 1 ) {
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

    ### UTF CHECKS ###
    local $utfsubj = $pms->get('Subject:raw');
    local $utffrom = $pms->get('From:raw');
    local $utfto = $pms->get('To:raw');
    local $utfreply = $pms->get('Reply-To:raw');
    $set = 0;
    $score = 0.01;
    
    $count = 0;    
    $rulename = "";
    $count = () = $utfsubj =~ /(utf\-8)/gi;
    $description = "CHAOS: ";
    if ($count >= 1) {
        if ( $utfsubj =~ /utf\-8\?q\?/gi ) {
            $rulename = "JR_SUBJ_UTF8_QP";
            $description .= "Subject has UTF-8 Quoted-Printable Coding";
            
        } elsif ( $utfsubj =~ /utf\-8\?b\?/gi ) {
            $rulename = "JR_SUBJ_UTF8_B64";
            $description .= "Subject has UTF-8 Base-64 Coding";
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    $count = 0; 
    $rulename = "";
    $count = () = $utffrom =~ /(utf\-8)/gi;
    $description = "CHAOS: ";
    if ($count >= 1) {
        if ( $utffrom =~ /utf\-8\?q\?/gi ) {
            $rulename = "JR_FROM_UTF8_QP";
            $description .= "From Name has UTF-8 Quoted-Printable Coding";
            
        } elsif ( $utffrom =~ /utf\-8\?b\?/gi ) {
            $rulename = "JR_FROM_UTF8_B64";
            $description .= "From Name has UTF-8 Base-64 Coding";
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    $count = 0; 
    $rulename = "";
    $count = () = $utfto =~ /(utf\-8)/gi;   
    $description = "CHAOS: ";
    if ($count >= 1) {
        if ( $utfto =~ /utf\-8\?q\?/gi ) {
            $rulename = "JR_TO_UTF8_QP";
            $description .= "To Name has UTF-8 Quoted-Printable Coding";
            
        } elsif ( $utfto =~ /utf\-8\?b\?/gi ) {
            $rulename = "JR_TO_UTF8_B64";
            $description .= "To Name has UTF-8 Base-64 Coding";
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    $count = 0; 
    $rulename = "";
    $count = () = $utfreply =~ /(utf\-8)/gi;    
    $description = "CHAOS: ";
    if ($count >= 1) {
        if ( $utfreply =~ /utf\-8\?q\?/gi ) {
            $rulename = "JR_REPLY_UTF8_QP";
            $description .= "Reply-To Name has UTF-8 Quoted-Printable Coding";
            
        } elsif ( $utfreply =~ /utf\-8\?b\?/gi ) {
            $rulename = "JR_REPLY_UTF8_B64";
            $description .= "Reply-To Name has UTF-8 Base-64 Coding";
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    ### USER-AGENTS ###
    local $uagent = $pms->get("User-Agent", undef);
    $set = 0;
    $count = 0;
    $mode = $pms->{conf}->{chaos_mode};
    $rulename = "JR_UNK_USR_AGENT";
    $score = 0.01;
    $description = "CHAOS: ";
    
    if ( defined $uagent ) {
        chomp $uagent;
        if ( $uagent =~ /Roundcube[\s_]Webmail/g ) {
            $description .= "Roundcube Webmail headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_ROUNDCUBE";
        } elsif ( $uagent =~ /SquirrelMail\//g ) {
            $description .= "SquirrelMail Webmail headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_SQUIRRELMAIL";
        } elsif ( $uagent =~ /Workspace[\s_]Webmail/g ) {
            $description .= "GoDaddy Webmail headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_DADDYMAIL";
        } elsif ( $uagent =~ /Thunderbird/g ) {
            $description .= "Thunderbird Email Client headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_THUNDERBIRD";
        } elsif ( $uagent =~ /Horde[\s_]Application[\s_]Framework/g ) {
            $description .= "Horde Webmail headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_HORDE";
        } elsif ( $uagent =~ /Internet[\s_]Messaging[\s_]Program/g ) {
            $description .= "Horde old Webmail (IMP) headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_HORDE";
        } elsif ( $uagent =~ /Alpine/g ) {
            $description .= "Alpine Linux headers detected";
            $score = 0.01;
            $count++;
            $rulename = "JR_ALPINE";
        } elsif ( $uagent =~ /MacOutlook/g ) {
            $description .= "Microsoft Outlook on an Apple Mac detected";
            $score = 0.01;
            $count++;
            $rulename = "JR_MAC_OUTLOOK";
        } elsif ( $uagent =~ /Mutt\//g ) {
            $description .= "Unix Mutt User-Agent detected";
            $score = 0.01;
            $count++;
            $rulename = "JR_MUTT";
        } elsif ( $uagent =~ /^KMail\//g ) {
            $description .= "Linux KDE KMail detected";
            $score = 0.01;
            $count++;
            $rulename = "JR_KMAIL";
        } elsif ( $uagent =~ /Zoho[\s_]Mail/g ) {
            if ( $zohocnt == 0 ) {
                $description .= "Zoho Mailer";
                $score = 0.01;
                $count++;
                $rulename = "JR_ZOHO";
            }
        } elsif ( $uagent =~ /eM_Client\//g ) {
            $description .= "Czech full-featured Email program - eM Client";
            $score = 0.01;
            $count++;
            $rulename = "JR_EMCLIENT";
        } elsif ( $uagent =~ /^Android/g ) {
            $description .= "Generic Android device detected";
            $score = 0.01;
            $count++;
            $rulename = "JR_ANDROID";
        } elsif ( $uagent =~ /_Emacs\//g ) {
            $description .= "GNU Emacs Editor";
            $score = 0.01;
            $count++;
            $rulename = "JR_EMACS";
        } elsif ( $uagent =~ /RedCappi[\s_]Mailer/g ) {
            $description .= "RedCappi Email Marketing Platform";
            $score = 0.01;
            $count++;
            $rulename = "JR_REDCAPPI";
        } elsif ( $uagent =~ /AddEmail[\s_]ActiveX/g ) {
            $description .= "Traysoft ActiveX/OCX Controls for SMTP";
            $score = 0.01;
            $count++;
            $rulename = "JR_TRAYSOFT";
        } elsif ( $uagent =~ /Jino[\s_]Webmail/g ) {
            $description .= "Jino Webmail (Russia)";
            $score = 0.01;
            $count++;
            $rulename = "JR_JINO";
            if ( $mode eq "AutoISP" ) { 
                $score = 0.3 * $pms->{conf}->{chaos_tag};
            }
		} elsif ( $uagent =~ /SeaMonkey/g ) {
            $description .= "Thunderbird Email Client headers observed";
            $score = 0.01;
            $count++;
            $rulename = "JR_SEAMONKEY";
        } elsif ( $uagent =~ /iPhoneOS\//g ) {
            $count = 0;
        } elsif ( $uagent =~ /iPadOS\//g ) {
            $count = 0;
        } elsif ( $uagent =~ /Dondley|goneo\b/ ) {
            $count = 0;
        } else {
            $rulename = "JR_UNK_USR_AGENT";
            $description .= "Unknown User-Agent: $uagent";
            $score = 0.01;
            $count++;
        }

        if ( $count >= 1 ) {
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    } 
    
    ### OTHER TESTS ###
    local $spanska = $pms->get("X-Spanska", undef);
    local $xcell = $pms->get("X-Cell-Line", undef);
    local $cruise = $pms->get("X-Cruiseplanners", undef);
    local $xcomp = $pms->get("Company", undef);
    local $xsentby1 = $pms->get("X-Mailer-Sent-By", undef);
    local $xbeenthere = $pms->get("X-BeenThere", undef);
    local $xiber = $pms->get("X-iberescudo-IberEscudo", undef);
    local $prec1 = $pms->get("Precedence", undef);
    local $prec2 = $pms->get("X-SubmittedType", undef);
    local $prec3 = $pms->get("X-CTCH-Spam", undef);
    local $headall = $pms->get('ALL');
    local $sgreference = $pms->get('References', undef);
    local $sg_eid = $pms->get("X-SG-EID", undef);
    $set = 0;
    $score = 0.01;
    $count = 0;
    $rulename = "";
    
    ### SENDGRID ###
    if ( $headall =~ /\bsendgrid\.net\b/g ) {
        $count++;
        if ( $sgreference =~ /\bsendgrid\.net\b/g ) {
            $count--;
        }
        if ( defined $sg_eid ) {
            $count++;
        }
        if ( $count == 0 ) {
            $rulename = "JR_SGRID_FWD";
            $description = "CHAOS: SendGrid Email forwarded by User/ISP";
            if ( $mode eq "AutoISP" ) { 
                $score = 0.1 * $pms->{conf}->{chaos_tag};
            }
        } else {
            $rulename = "JR_SGRID_DIRECT";
            
            if ( $mode eq "AutoISP" ) { 
                $score = 0.27 * $pms->{conf}->{chaos_tag};
            }
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    ### KLAVIYO ###
    $set = 0;
    $score = 0.01;
    $count = 0;
    $rulename = "";
    $description = "";
    if ( $headall =~ /\b(klaviyomail\.com|krelaymail\.com)\b/g ) {
        $rulename = "JR_KLAVIYO";
        $description = "CHAOS: Sent using Klaviyo";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    
    ### SWIFTMAILER (POD X-MAILER CATEGORY) ###
    $set = 0;
    $score = 0.01;
    $count = 0;
    $rulename = "";
    $description = "CHAOS: ";
    if ( $headall =~ /\bSwiftMailer\b/g ) {
        $rulename = "JR_SWIFTMAILER";
        $description = "CHAOS: Sent using SwiftMailer";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.57 * $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    
    ### BOGUS/BAD HEADERS ###
    $set = 0;
    $count = 0;
    $mode = $pms->{conf}->{chaos_mode};
    $rulename = "JR_BOGUS_HEADERS";
    $score = 0.01;
    $description = "CHAOS: ";
        if ( defined $spanska ) {
        $count++;
        $description .= "Invalid X-Spanska header observed";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
    }
    if ( defined $xcell ) {
        $count++;
        $description .= "Invalid X-Cell-Line header observed";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
    }
    if ( defined $cruise) {
        $count++;
        $description .= "Invalid X-Cruiseplanners header observed";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
    }
    if ( defined $xcomp) {
        $count++;
        $description .= "Invalid Company header observed";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
    }
    if ( $count >= 1) {
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    if ( defined $xbeenthere ) {
        $count = 0;
        $set = 0;
        $description = "CHAOS: ";
        $score = 0.01;
        chomp $xbeenthere;
        $rulename = "JR_X_BEENTHERE";
        $description .= "This messages has the X-BeenThere header";
            if ( $mode eq "AutoISP" ) { 
                $score = 0.18 * $pms->{conf}->{chaos_tag};
            }
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
        
    if ( defined $xsentby1 ) {
        $count = 0;
        $set = 0;
        $description = "CHAOS: ";
        $score = 0.01;
        chomp $xsentby1;
        if ( $xsentby1 =~ /^[0-9a-zA-Z]$/ ) {
            $rulename = "JR_X_SENTBY";
            $description .= "Bad X-Mailer-Sent-By header: $xsentby1";
            if ( $mode eq "AutoISP" ) { 
                $score = 0.23 * $pms->{conf}->{chaos_tag};
            }
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
    
    if ( defined $xiber ) {
        if ( $xiber =~ /Mensaje\sno\sverificado\!\!/ ) {
            $count = 0;
            $set = 0;
            $description = "CHAOS: ";
            $score = 0.01;
            chomp $xiber;
            $rulename = "JR_X_UNVERIFIED";
            $description .= "This message is reported as Unverified";
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.2 * $pms->{conf}->{chaos_tag};
                }
                $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                $pms->got_hit("$rulename", "", score => $score);
                $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
    ### CHECK BULK HEADERS ###
    $score = 0.01;
    $count = 0;
    $set = 0;
    $description = "CHAOS: ";
    $rulename = "JR_BULK";
    if (( defined $prec1 ) &&  ( $prec1 =~ /bulk/i )) {
            $count++;
            $description .= "Bulk Precedence header detected";
    }
    if (( defined $prec2 ) &&  ( $prec2 =~ /bulk/i )) {
            $count++;
            $description .= "Bulk X-SubmittedType header detected";
    }
    if (( defined $prec3 ) &&  ( $prec3 =~ /bulk/i )) {
            $count++;
            $description .= "Bulk X-CTCH-Spam header detected";
    }
    if ( $count >= 1 ) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.12 * $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    } 
    
    ### MAILCHIMP SPOOFS ###
    ### https://mailchimp.com/developer/transactional/docs/smtp-integration/
    local $mcsendat = $pms->get("X-MC-SendAt", undef);
    local $mcbcc = $pms->get("X-MC-BccAddress", undef);
    local $mcview = $pms->get("X-MC-ViewContentLink", undef);
    $set = 0;
    $count = 0;
    $score = 0.01;
    $rulename = "JR_BAD_CHIMP";
    $description = "CHAOS: Invalid Mailchimp header:";
    if (( defined $mcsendat ) && ( $mcsendat =~ /[[:lower:][:upper:]]/ )) {
        $description .= " $mcsendat";
        $count++;
    }
    if ( defined $mcbcc ) {
        unless($mcbcc =~ /[[:lower:][:digit:]\.\-\_]+\@[[:lower:][:digit:]\.\_\-]+/) {
            $description .= " $mcbcc";
            $count++;
        }
    } 
    if ( defined $mcview ) {
        unless($mcview =~ /(true|false|1|0)/i) {
            $description .= " $mcview";
            $count++;
        }
    }
    if ( $count >= 1) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.6 * $pms->{conf}->{chaos_tag};
        }
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    ### EXCHANGE SPOOFS ###
    local $exch1 = $pms->get("X-MS-Exchange-CrossTenant-AuthAs", undef);
    local $exch2 = $pms->get("X-MS-Exchange-Organization-AuthAs", undef);
    local $exch3 = $pms->get("X-MS-Exchange-Organization-AuthMechanism", undef);
    local $exch4 = $pms->get("X-MS-Has-Attach", undef);
    local $exch5 = $pms->get("X-MS-TNEF-Correlator", undef);
    local $exch6 = $pms->get("X-MS-Exchange-CrossTenant-FromEntityHeader", undef);
    local $exch7 = $pms->get("X-MS-Exchange-Organization-FromEntityHeader", undef);
    local $exch8 = $pms->get("X-MS-Exchange-CrossTenant-id", undef);
    local $exch9 = $pms->get("x-incomingtopheadermarker", undef);
    local $exch10 = $pms->get("X-MS-Exchange-Transport-CrossTenantHeadersStamped", undef);
    local $exch11 = $pms->get("X-MS-Exchange-Transport-fromentityheader", undef);
    local $exch12 = $pms->get("X-MS-PublicTrafficType", undef);
    $set = 0;
    $count = 0;
    $score = 0.01;
    $rulename = "JR_EXCHANGE";
    $description = "CHAOS: ";
    if ( defined $exch1 ) {
        chomp $exch1;
        $count++;
        unless($exch1 =~ /(Internal|External|Anonymous)/) {
            $score = 0.01;
            if ( $mode eq "AutoISP" ) { 
                $score = 0.25 * $pms->{conf}->{chaos_tag};
            }
            $rulename = "JR_EXCH_BAD_AUTH";
            $description = "CHAOS: Invalid MS Exchange AuthAs header";
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
        }
    }
    if ( defined $exch2 ) {
        chomp $exch2;
        $count++;
        unless($exch2 =~ /(Internal|External|Anonymous)/) {
            $score = 0.01;
            if ( $mode eq "AutoISP" ) { 
                $score = 0.25 * $pms->{conf}->{chaos_tag};
            }
            $rulename = "JR_EXCH_BAD_AUTH";
            $description = "CHAOS: Invalid MS Exchange AuthAs header";
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
        }
    }
    if ( defined $exch3 ) {
        chomp $exch3;
        $count++;
        unless( $exch3 =~ /[0-9A-F][0-9A-F]/i ) {
            $score = 0.01;
            if ( $mode eq "AutoISP" ) { 
                $score = 0.25 * $pms->{conf}->{chaos_tag};
            }
            $rulename = "JR_EXCHANGE_AUTH";
            $description = "CHAOS: Invalid MS Exchange Auth Mechanism";
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
    if ( defined $exch4 ) {
        chomp $exch4;
        $count++;
        unless(( $exch4 =~ m/yes/i ) || ( $exch4 eq '' ))  {
            $score = 0.01;
            if ( $mode eq "AutoISP" ) { 
                $score = 0.25 * $pms->{conf}->{chaos_tag};
            }
            $rulename = "JR_EXCH_ATTACH";
            $description = "CHAOS: Invalid MS Attachment value: $exch4";
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
    if ( defined $exch5 ) {
        chomp $exch5;
        $count++;
    }
    if ( defined $exch6 ) {
        chomp $exch6;
        $count++;
    }
    if ( defined $exch7 ) {
        chomp $exch7;
        $count++;
    }
    if ( defined $exch8 ) {
        chomp $exch8;
        $count++;
    }
    if ( defined $exch9 ) {
        chomp $exch9;
        $count++;
    }
    if ( defined $exch10 ) {
        chomp $exch10;
        $count++;
    }
    if ( defined $exch11 ) {
        chomp $exch11;
        $count++;
    }
    if ( defined $exch12 ) {
        chomp $exch12;
        $count++;
        unless( $exch12 =~ /^Email$/i ) {
            $score = 0.01;
            if ( $mode eq "AutoISP" ) { 
                $score = 0.25 * $pms->{conf}->{chaos_tag};
            }
            $rulename = "JR_EXCHANGE_TYPE";
            $description = "CHAOS: Invalid MS Exchange Traffic Type Designator";
            $pms->{conf}->{descriptions}->{"$rulename"} = $description;
            $pms->got_hit("$rulename", "", score => $score);
            $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
        }
    }
    if ( $count >= 3) {
        $set = 0;
        $score = 0.01;
        $rulename = "JR_EXCHANGE";
        $description = "CHAOS: MS Exchange headers detected";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    ### DUPLICATE HEADERS ###
    local $allhdrs = $pms->get("ALL");
    $set = 0;
    $count = 0;
    $score = 0.01;
    local $cntsubj = 0;
    local $cntfrom = 0;
    local $cntsndr = 0;
    local $cntrep = 0;
    local $cntto = 0;
    local $cntcc = 0;
    local $cntbcc = 0;
    local $cntmsgid = 0;
    local $cntrefr = 0;
    local $cntexch1 = 0;
    local $cntexch2 = 0;
    local $cntexch3 = 0;
	local $cntexch4 = 0;
	local $cntexch5 = 0;
	local $cntexch6 = 0;
    local $pri1 = 0;
    local $pri2 = 0;
    local $pri3 = 0;
    $rulename = "JR_DUP_HDRS";
    $description = "CHAOS: ";
    local %seen;
    open my $fh, '<', \$allhdrs;
    while (my $line = <$fh>) {
        chomp $line;
        unless ( $line =~ /^Resent-Date:|^Resent-From:|^Resent-Sender:|^Resent-To:|^Resent-Cc:|^Resent-Bcc:|^Resent-Message-ID:|^Comments:|^Keywords:|^Received|^X-Sender-Id:/i ) {
            if ( defined $seen{$line} ) {
                $count++;
            } else {
                $seen{$line}++;
            }
            if ( $line =~ /^Subject:/i ) {
                $cntsubj++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^From:/i ) {
                $cntfrom++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^Sender:/i ) {
                $cntsndr++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^Reply-To:/i ) {
                $cntrep++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^To:/i ) {
                $cntto++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^Cc:/i ) {
                $cntcc++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^Bcc:/i ) {
                $cntbcc++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^Message-Id:/i ) {
                $cntmsgid++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }
            }
            if ( $line =~ /^References:/i ) {
                $cntrefr++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-MS-Exchange-CrossTenant-FromEntityHeader:/i ) {
                $cntexch1++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.3 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-OriginalArrivalTime:/i ) {
                $cntexch2++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.4 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-MS-Exchange-Organization-FromEntityHeader:/i ) {
                $cntexch3++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.3 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-MS-Exchange-CrossTenant-AuthAs:/i ) {
                $cntexch4++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.3 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-MS-Exchange-Organization-AuthAs:/i ) {
                $cntexch5++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.3 * $pms->{conf}->{chaos_tag};
                }       
            }
			if ( $line =~ /^X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg:/i ) {
                $cntexch6++;
                if ( $mode eq "AutoISP" ) { 
                    $score = 0.25 * $pms->{conf}->{chaos_tag};
                }       
            }
            if ( $line =~ /^X-Priority:/i ) {
                $pri1++;
            }
            if ( $line =~ /^X-Msmail-Priority:/i ) {
                $pri2++;
            }
            if ( $line =~ /^Importance:/i ) {
                $pri3++;
            }

        }
    }
    close $fh;
        
    if ( $count >= 1 ) {
        $description .= "Identical Message headers detected: $count";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }
    $set = 0;
    $score = 0.01;
    $description = "CHAOS: ";
    $rulename = "JR_PRI_MULTI";
    if (( $pri1 >= 1 ) && ( $pri2 >= 1 ) && ( $pri3 >= 1 )) {
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
        $description .= "Many different Priority headers detected";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }   
    
    # Find standard field names that should only exist once per RFC5322
    $set = 0;
    $count = 0;
    $score = 0.01;
    $rulename = "JR_MULTI_HDRS";
    $description = "CHAOS: ";
    if ( $cntsubj >= 2 ) {
        $count++;
        $description .= "Multiple Subject headers not allowed- RFC5322: $cntsubj";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntfrom >= 2 ) {
        $count++;
        $description .= "Multiple From headers not allowed- RFC5322: $cntfrom";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntsndr >= 2 ) {
        $count++;
        $description .= "Multiple Sender headers not allowed- RFC5322: $cntsndr";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntrep >= 2 ) {
        $count++;
        $description .= "Multiple Reply-To headers not allowed- RFC5322: $cntrep";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntto >= 2 ) {
        $count++;
        $description .= "Multiple To headers not allowed- RFC5322: $cntto";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntcc >= 2 ) {
        $count++;
        $description .= "Multiple Cc headers not allowed- RFC5322: $cntcc";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntbcc >= 2 ) {
        $count++;
        $description .= "Multiple Bcc headers not allowed- RFC5322: $cntbcc";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntmsgid >= 2 ) {
        $count++;
        $description .= "Multiple Message-Id headers not allowed- RFC5322: $cntmsgid";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntrefr >= 2 ) {
        $count++;
        $description .= "Multiple References headers not allowed- RFC5322: $cntrefr";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.4 * $pms->{conf}->{chaos_tag};
        }
    } elsif ( $cntexch1 >= 2 ) {
        $count++;
        $description .= "Multiple X-MS-Exchange-CrossTenant-FromEntityHeaders: $cntexch1";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }   
    } elsif ( $cntexch2 >= 2 ) {
        $count++;
        $description .= "Multiple X-OriginalArrivalTime headers: $cntexch2";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.3 * $pms->{conf}->{chaos_tag};
        }   
    } elsif ( $cntexch6 >= 2 ) {
        $count++;
        $description .= "Multiple X-MS-Exchange-CrossTenant-RMS-PersistedConsumerOrg headers: $cntexch6";
        if ( $mode eq "AutoISP" ) { 
            $score = 0.25 * $pms->{conf}->{chaos_tag};
        }   
    }   
    if ( $count > 0 ) {
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }   
         
return 0;
}


=head2  id_attachments()

=over 5

=item  This is a check of the 'Content-Type' MIME headers for potentially bad attachments.  These include Archive, MS Office/Works, RTF, PDF, Boot Image, Executable Program, and HTML, file attachments.  These are immutable Callouts, and each have a score of 0.01.

    JR_ATTACH_ARCHIVE         JR_ATTACH_RTF
    JR_ATTACH_PDF             JR_ATTACH_BOOTIMG
    JR_ATTACH_MSOFFICE        JR_ATTACH_EXEC
    JR_ATTACH_OPENOFFICE      JR_ATTACH_HTML
    JR_ATTACH_RISK

=item  JR_ATTACH_RISK is rule that is also set if ANY of the above rules are matched.  

=back

=over 5

=item  The following immutable rules are specific callouts for JPG, ZIP, CAB, and GZ files.  

    JR_ATTACH_ZIP       JR_ATTACH_GZIP
    JR_ATTACH_JPEG      JR_ATTACH_CAB
    JR_ATTACH_IMAGE
    
=back

=over 5

=item   The callout rule, JR_ATTACH_IMAGE, is set when ANY (jpg,gif,png,bmp,etc.) common image attachment is detected.

=back

=over 5

=item  If an attachment filename is the same as the Message Subject, the rule JR_SUBJ_ATTACH_NAME is set.  This is scored at a callout level of 0.01 except in Auto mode. 

=back

=cut

sub id_attachments {
    my ( $self, $pms ) = @_;
    local $rulename = "";
    local $file = "";
    local $count = 0;
    local $acount = 0;
    local $pcount = 0;
    local $mcount = 0;
    local $cabcount = 0;
    local $rcount = 0;
    local $bcount = 0;
    local $ecount = 0;
    local $hcount = 0;
    local $icount = 0;
    local $jcount = 0;
    local $zipcount = 0;
    local $gzcount = 0;
    local $set = 0;
    local $score = 0.01;
    local $subject = $pms->get('Subject');
    chomp $subject;
    local $msg = $pms->get_message();
    local $mode = $pms->{conf}->{chaos_mode};

    # print Dumper($test);
    # Mail::SpamAssassin::PerMsgStatus::enter_helper_run_mode($self);

    # foreach my $p ($pms->{msg}->find_parts(qr/./)) {
     my @types = (
        qr(application/x-tar)i,
        qr(application/zip)i,
        qr(application/x-gzip)i,
        qr(application/x-gtar)i,
        qr(application/x-compressed)i,
        qr(application/vnd.ms-cab-compressed)i,
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
                my $score1 = 0.01;
                if ( $mode eq "AutoISP" ) { 
                    $score1 = $pms->{conf}->{chaos_tag} * 0.58;
                }
                my $description1 = "CHAOS: The attached filename and the Subject are the same";
                $pms->{conf}->{descriptions}->{"$rulename1"} = $description;
                $pms->got_hit("$rulename1", "BODY: ", score => $score1);
                $pms->{conf}->{scoreset}->[$set]->{"$rulename1"} = sprintf("%0.4f", $score1);
            }
            # print Dumper($p);
            $score = 0.01;
            if ( $file =~ /.*(\.tgz|\.zip|\.zipx|\.xz|\.z|\.x\-rar|\.jar|\.r00|\.arc|\.gz|\.bz|\.bz2|\.tar|\.cpio|\.bcpio|\.sit|\.lzh|\.lha|\.r09|\.cab)\"?/gi ) {
                $rulename = "JR_ATTACH_ARCHIVE";
                $description = "CHAOS: A file Archive is attached";
                if ( $acount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $acount++;
                }
                if (( $zipcount == 0 ) && ( $file =~ /.*(\.zip|\.zipx)\"?/gi )) {
                    $rulename = "JR_ATTACH_ZIP";
                    $description = "CHAOS: A ZIP file is attached";
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $zipcount++;
                }
                if (( $gzcount == 0 ) && ( $file =~ /.*(\.gz)\"?/gi )) {
                    $rulename = "JR_ATTACH_GZIP";
                    $description = "CHAOS: A GZIP file is attached";
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $gzcount++;
                }
                if (( $gzcount == 0 ) && ( $file =~ /.*(\.cab)\"?/gi )) {
                    $rulename = "JR_ATTACH_CAB";
                    $description = "CHAOS: A Windows CAB archive is attached";
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $cabcount++;
                }
                    
            } elsif ( $file =~ /.*([\._]pdf\.img|\.pdf)\"?/gi ) {
                $rulename = "JR_ATTACH_PDF";
                $description = "CHAOS:  A PDF file is attached";
                if ( $pcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $pcount++;
                    
                }
            } elsif ( $file =~ /.*(\.doc|\.dot|\.docx|\.dotx|\.docm|\.dotm|\.xls|\.xlt|\.xla|\.xlw|\.xlc|\.xlsx|\.xltx|\.xlsm|\.xltm|\.xlam|\.xlsb|\.ppt|\.pps|\.ppa|\.pot|\.pptx|\.potx|\.ppsx|\.ppam|\.pptm|\.potm|\.ppsm|\.mdb|\.mpp|\.wcm|\.wdb|\.wks|\.wps)\"?/gi ) {
                $rulename = "JR_ATTACH_MSOFFICE";
                $description = "CHAOS: Microsoft document attached";
                if ( $mcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $mcount++;
                }
            } elsif ( $file =~ /.*(\.odt|\.ott|\.oth|\.odm|\.odg|\.otg|\.odp|\.otp|\.ods|\.ots|\.odc|\.odf|\.odb|\.odi|\.oxt)\"?/gi ) {
                $rulename = "JR_ATTACH_OPENOFFICE";
                $description = "CHAOS: An OpenOffice document is attached";
                if ( $mcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $mcount++;
                }
            } elsif ( $file =~ /.*(\.rtf)\"?/gi ) {
                $rulename = "JR_ATTACH_RTF";
                $description = "CHAOS: A RTF document is attached";
                if ( $rcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $rcount++;
                }
            } elsif ( $file =~ /.*(\.iso|\.img|\.daa|\.dwg)\"?/gi ) {
                $rulename = "JR_ATTACH_BOOTIMG";
                $description = "CHAOS: Boot image attached";
                if ( $bcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $bcount++;
                }
            } elsif ( $file =~ /.*(\.exe|\.hqx|\.cmd|\.bin|\.hta|\.hlp|\.pif|\.class|\.dll|\.msi)\"?/gi ) {
                $rulename = "JR_ATTACH_EXEC";
                $description = "CHAOS: An Executable file is attached";
                if ( $ecount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $ecount++;
                }
            } elsif ( $file =~ /.*(\.htm|\.html)\"?/i ) {
                $rulename = "JR_ATTACH_HTML";
                $description = "CHAOS: A HTML file is attached";
                if ( $hcount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
                    $hcount++;
                }
            } elsif ( $file =~ /.*(\.jpe|\.jpeg|\.jpg|\.bmp|\.gif|\.svg|\.tif|\.tiff|\.wmf|\.emf|\.png)\"?/gi ) {
                $rulename = "JR_ATTACH_IMAGE";
                $description = "CHAOS: An Image file is attached";
                if ( $icount == 0 ) { 
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score);
                    $icount++;
                }
                if (( $jcount == 0 ) && ( $file =~ /.*(\.jpe|\.jpg|\.jpeg)\"?/gi )) {
                    $rulename = "JR_ATTACH_JPEG";
                    $description = "CHAOS: A JPEG Image is attached";
                    $pms->{conf}->{descriptions}->{"$rulename"} = $description;
                    $pms->got_hit("$rulename", "BODY: ", score => $score);
                    $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
                    $jcount++;
                }
            }
                
        }
    }

    $count = $acount + $cabcount + $pcount + $mcount + $rcount + $bcount + $ecount + $hcount;
    if ( $count >= 1 ) {
        $rulename = "JR_ATTACH_RISK";
        $description = "CHAOS: This Email contains a dangerous file type";
        $pms->{conf}->{descriptions}->{"$rulename"} = $description;
        $pms->got_hit("$rulename", "BODY: ", score => $score);
        $pms->{conf}->{scoreset}->[$set]->{"$rulename"} = sprintf("%0.4f", $score); 
    }

return 0;
}


=head1  PREREQUISITES

=over 5

=item  PERL version 5.18, 5.22 or later

=item  SpamAssassin 3.4.2 or later with its standard PERL libraries

=back


=head1  INSTALLATION

=over 5

=item  Copy the files, CHAOS.pre, CHAOS.cf, and CHAOS.pm to your SpamAssassin system folder.  This is usually /etc/spamassassin or /etc/mail/spamassassin.

=item  Edit/Change the CHAOS.cf file to your liking.

=item  If running with a Policy Daemon like Amavis, Policyd, MIMEDefang, etc., make sure that you restart that after installation or after making any changes.

=back


=head1  DIAGNOSTICS

=over 5

=item  CHAOS.pm supports versioning and can provide additonal details about your SpamAssassin configuration:

=item  
    perl /$PATH_TO/CHAOS.pm [-v, --version]  # CHAOS.pm, PERL, SA Version             
    perl /$PATH_TO/CHAOS.pm [-V, --verbose]  # Above + PERL libraries for SA
    perl /$PATH_TO/CHAOS.pm [-VV, --very]    # Above + SA physical file paths

=back


=head1  MORE DOCUMENTATION

=over 5

=item  See also <https://spamassassin.apache.org/> and <https://wiki.apache.org/spamassassin/> for more information.  

=back

=over 5

=item  See this project's Wiki for more information: https://github.com/telecom2k3/CHAOS/wiki/ 

=back

=head1  SEE ALSO

=over 5

=item  Mail::SpamAssassin::Conf(3) 

=item  Mail::SpamAssassin::PerMsgStatus(3) 

=item  Mail::SpamAssassin::Plugin

=back

=head1  BUGS

=over 5

=item  While I do follow SA-User's, please do NOT report bugs there; I'm not glued-in to that list.

=item  If you are uncomfortable with Github problem reporting, you can always report problems by E-Mail.  See the AUTHOR section below for contact information.

=back

=head1 AUTHOR

=over 5

=item  Jared Hall, <jared@jaredsec.com> or <telecom2k3@gmail.com>

=back

=head1  CAVEATS

=over 5

=item  The author does NOT accept any liability for YOUR use of this software. If a particular Eval rule herein does not meet your requirements please disable (comment out) the rule and report the problem.  See the BUGS section for information regarding problem reporting.

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
    
    $jr_line5 = qr/\xF0\x9F\x92\x80|\xF0\x9F\x92\x81|\xF0\x9F\x92\x82|\xF0\x9F\x92\x83|\xF0\x9F\x92\x84|\xF0\x9F\x92\x85|\xF0\x9F\x92\x86|\xF0\x9F\x92\x87|\xF0\x9F\x92\x88|\xF0\x9F\x92\x89|\xF0\x9F\x92\x8A|\xF0\x9F\x92\x8B|\xF0\x9F\x92\x8C|\xF0\x9F\x92\x8D|\xF0\x9F\x92\x8E|\xF0\x9F\x92\x8F|\xF0\x9F\x92\x90|\xF0\x9F\x92\x91|\xF0\x9F\x92\x92|\xF0\x9F\x92\x93|\xF0\x9F\x92\x94|\xF0\x9F\x92\x95|\xF0\x9F\x92\x96|\xF0\x9F\x92\x97|\xF0\x9F\x92\x98|\xF0\x9F\x92\x99|\xF0\x9F\x92\x9A|\xF0\x9F\x92\x9B|\xF0\x9F\x92\x9C|\xF0\x9F\x92\x9D|\xF0\x9F\x92\x9E|\xF0\x9F\x92\x9F|\xF0\x9F\x92\xA0|\xF0\x9F\x92\xA1|\xF0\x9F\x92\xA2|\xF0\x9F\x92\xA3|\xF0\x9F\x92\xA4|\xF0\x9F\x92\xA5|\xF0\x9F\x92\xA6|\xF0\x9F\x92\xA7|\xF0\x9F\x92\xA8|\xF0\x9F\x92\xA9|\xF0\x9F\x92\xAA|\xF0\x9F\x92\xAB|\xF0\x9F\x92\xAC|\xF0\x9F\x92\xAD|\xF0\x9F\x92\xAE|\xF0\x9F\x92\xAF|\xF0\x9F\x92\xB0|\xF0\x9F\x92\xB1|\xF0\x9F\x92\xB2|\xF0\x9F\x92\xB3|\xF0\x9F\x92\xB4|\xF0\x9F\x92\xB5|\xF0\x9F\x92\xB6|\xF0\x9F\x92\xB7|\xF0\x9F\x92\xB8|\xF0\x9F\x92\xB9|\xF0\x9F\x92\xBA|\xF0\x9F\x92\xBB|\xF0\x9F\x92\xBC|\xF0\x9F\x92\xBD|\xF0\x9F\x92\xBE|\xF0\x9F\x92\xBF|\xF0\x9F\x93\x80|\xF0\x9F\x93\x81|\xF0\x9F\x93\x82|\xF0\x9F\x93\x83|\xF0\x9F\x93\x84|\xF0\x9F\x93\x85|\xF0\x9F\x93\x86|\xF0\x9F\x93\x87|\xF0\x9F\x93\x88|\xF0\x9F\x93\x89|\xF0\x9F\x93\x8A|\xF0\x9F\x93\x8B|\xF0\x9F\x93\x8C|\xF0\x9F\x93\x8D|\xF0\x9F\x93\x8E|\xF0\x9F\x93\x8F|\xF0\x9F\x93\x90|\xF0\x9F\x93\x91|\xF0\x9F\x93\x92|\xF0\x9F\x93\x93|\xF0\x9F\x93\x94|\xF0\x9F\x93\x95|\xF0\x9F\x93\x96|\xF0\x9F\x93\x97|\xF0\x9F\x93\x98|\xF0\x9F\x93\x99|\xF0\x9F\x93\x9A|\xF0\x9F\x93\x9B|\xF0\x9F\x93\x9C|\xF0\x9F\x93\x9D|\xF0\x9F\x93\x9E|\xF0\x9F\x93\x9F|\xF0\x9F\x93\xA0|\xF0\x9F\x93\xA1|\xF0\x9F\x93\xA2|\xF0\x9F\x93\xA3|\xF0\x9F\x93\xA4|\xF0\x9F\x93\xA5|\xF0\x9F\x93\xA6|\xF0\x9F\x93\xA7|\xF0\x9F\x93\xA8|\xF0\x9F\x93\xA9|\xF0\x9F\x93\xAA|\xF0\x9F\x93\xAB|\xF0\x9F\x93\xAC|\xF0\x9F\x93\xAD|\xF0\x9F\x93\xAE|\xF0\x9F\x93\xAF|\xF0\x9F\x93\xB0|\xF0\x9F\x93\xB1|\xF0\x9F\x93\xB2|\xF0\x9F\x93\xB3|\xF0\x9F\x93\xB4|\xF0\x9F\x93\xB5|\xF0\x9F\x93\xB6|\xF0\x9F\x93\xB7|\xF0\x9F\x93\xB8|\xF0\x9F\x93\xB9|\xF0\x9F\x93\xBA|\xF0\x9F\x93\xBB|\xF0\x9F\x93\xBC|\xF0\x9F\x93\xBD|\xF0\x9F\x93\xBE|\xF0\x9F\x93\xBF|\xF0\x9F\x94\x80|\xF0\x9F\x94\x81|\xF0\x9F\x94\x82|\xF0\x9F\x94\x83|\xF0\x9F\x94\x84|\xF0\x9F\x94\x85|\xF0\x9F\x94\x86|\xF0\x9F\x94\x87|\xF0\x9F\x94\x88|\xF0\x9F\x94\x89|\xF0\x9F\x94\x8A|\xF0\x9F\x94\x8B|\xF0\x9F\x94\x8C|\xF0\x9F\x94\x8D|\xF0\x9F\x94\x8E|\xF0\x9F\x94\x8F|\xF0\x9F\x94\x90|\xF0\x9F\x94\x91|\xF0\x9F\x94\x92|\xF0\x9F\x94\x93|\xF0\x9F\x94\x94|\xF0\x9F\x94\x95|\xF0\x9F\x94\x96|\xF0\x9F\x94\x97|\xF0\x9F\x94\x98|\xF0\x9F\x94\x99|\xF0\x9F\x94\x9A|\xF0\x9F\x94\x9B|\xF0\x9F\x94\x9C|\xF0\x9F\x94\x9D|\xF0\x9F\x94\x9E|\xF0\x9F\x94\x9F|\xF0\x9F\x94\xA0|\xF0\x9F\x94\xA1|\xF0\x9F\x94\xA2|\xF0\x9F\x94\xA3|\xF0\x9F\x94\xA4|\xF0\x9F\x94\xA5|\xF0\x9F\x94\xA6|\xF0\x9F\x94\xA7|\xF0\x9F\x94\xA8|\xF0\x9F\x94\xA9|\xF0\x9F\x94\xAA|\xF0\x9F\x94\xAB|\xF0\x9F\x94\xAC|\xF0\x9F\x94\xAD|\xF0\x9F\x94\xAE|\xF0\x9F\x94\xAF|\xF0\x9F\x94\xB0|\xF0\x9F\x94\xB1|\xF0\x9F\x94\xB2|\xF0\x9F\x94\xB3|\xF0\x9F\x94\xB4|\xF0\x9F\x94\xB5|\xF0\x9F\x94\xB6|\xF0\x9F\x94\xB7|\xF0\x9F\x94\xB8|\xF0\x9F\x94\xB9|\xF0\x9F\x94\xBA|\xF0\x9F\x94\xBB|\xF0\x9F\x94\xBC|\xF0\x9F\x94\xBD|\xF0\x9F\x94\xBE|\xF0\x9F\x94\xBF|\xF0\x9F\x95\x80|\xF0\x9F\x95\x81|\xF0\x9F\x95\x82|\xF0\x9F\x95\x83|\xF0\x9F\x95\x84|\xF0\x9F\x95\x85|\xF0\x9F\x95\x86|\xF0\x9F\x95\x87|\xF0\x9F\x95\x88|\xF0\x9F\x95\x89|\xF0\x9F\x95\x8A|\xF0\x9F\x95\x8B|\xF0\x9F\x95\x8C|\xF0\x9F\x95\x8D|\xF0\x9F\x95\x8E|\xF0\x9F\x95\x8F|\xF0\x9F\x95\x90|\xF0\x9F\x95\x91|\xF0\x9F\x95\x92|\xF0\x9F\x95\x93|\xF0\x9F\x95\x94|\xF0\x9F\x95\x95|\xF0\x9F\x95\x96|\xF0\x9F\x95\x97|\xF0\x9F\x95\x98|\xF0\x9F\x95\x99|\xF0\x9F\x95\x9A|\xF0\x9F\x95\x9B|\xF0\x9F\x95\x9C|\xF0\x9F\x95\x9D|\xF0\x9F\x95\x9E|\xF0\x9F\x95\x9F|\xF0\x9F\x95\xA0|\xF0\x9F\x95\xA1|\xF0\x9F\x95\xA2|\xF0\x9F\x95\xA3|\xF0\x9F\x95\xA4|\xF0\x9F\x95\xA5|\xF0\x9F\x95\xA6|\xF0\x9F\x95\xA7|\xF0\x9F\x95\xA8|\xF0\x9F\x95\xA9|\xF0\x9F\x95\xAA|\xF0\x9F\x95\xAB|\xF0\x9F\x95\xAC|\xF0\x9F\x95\xAD|\xF0\x9F\x95\xAE|\xF0\x9F\x95\xAF|\xF0\x9F\x95\xB0|\xF0\x9F\x95\xB1|\xF0\x9F\x95\xB2|\xF0\x9F\x95\xB3|\xF0\x9F\x95\xB4|\xF0\x9F\x95\xB5|\xF0\x9F\x95\xB6|\xF0\x9F\x95\xB7|\xF0\x9F\x95\xB8|\xF0\x9F\x95\xB9|\xF0\x9F\x95\xBA|\xF0\x9F\x95\xBB|\xF0\x9F\x95\xBC|\xF0\x9F\x95\xBD|\xF0\x9F\x95\xBE|\xF0\x9F\x95\xBF/i;

return();
}

sub admin_match {
    $myadmin = qr/Important\salert\son\syour\saccount|Password\sExpire\sFor\s[a-z0-9.]+\@[a-z0-9.-]+|IT\sWarning\sfor\s[a-z0-9.]+\@[a-z0-9.-]+\sMailBox\sAccount|Warning\:\sEmail\supgrade\srequired\sfor\syour\smailbox\s\-|You\shave\s\[?\d+\]?\snew\spending\smails\son|You\shave\s\[?\d+\]?\sundelivered\smails\son|Retrieve\sPending\sMessages\sfor\s.*\@.*|New\sSecure\-mail\s\([0-9]{3,7}\)|New\smessage\s\([0-9]{1,3}\)|:\s:\sMail\sServer\sErrors|Email\sAdministrator\.|Several\semail\sMessages\sHindered\sfrom\sdelivery|ACCOUNT\sSHUTDOWN\sNOTIFICATION|There\sare\snew\smessages\sin\syour\sEmail\sQuarantine|Mail\sSystem\s\-\sNotification|Please\sverify\syour\semail\saccount\s[a-z0-9.]+\@[a-z0-9.-]+|You\shave\s\{\d\}\smessages\sundelivered\sfor\s[a-z0-9.\_]+\@[a-z0-9.-]+|mailbox:\sNew\sfound\smessages\sin\squarantine:|Please\sverify\syour\semail\saccount\s[a-z0-9.]+\@[a-z0-9.-]+|You\shave\s\{\d\}\smessages\sundelivered\sfor\s[a-z0-9.]+\@[a-z0-9.-]+|Urgent\sSecurity\sUpdate\sDocuments|Final\sWarning\,\sYour\sEmail|Email\sSuspension\s\(last\swarning\!\!\)|Attention:\sEmail\sOwner|Notice\s:\sYour\sEmail\sIs\sAt\sRisk|Mandatory\sEmail\sVerification\!|Confirm\sYour\sDelivery\sStatus|Upgrade\sMailbox|ACCOUNT\sSHUTDOWN|DE\-ACTIVATION\sREQUEST|Security\/Upgrade\sMaintainance\sready|Activate\sOne\-Time\sVerification\sOn\sYour\sEmail\sAccount|You\shave\s\{\d\}\smessages\sundelivered|Profile\sUpdate\srequired\sImmediately|Verify\sYour\sAccount\sOwnership|New\sSecure\sMessage|Action\sRequired:\sYou\shave\s\d\sblocked\smessages|^Account\sTermination\sRequest|IT\sWarning\sfor\s[a-z0-9._\-]+\@[a-z0-9.\-]+\sMailBox\sAccount|You\shave\s\[?\d+\]?\s(new\spending|undelivered)\smails|Password_Expiry_Notification|\([0-9]\)\sQuarantine\sMessages|Verify\syour\sIdentity|Mail\sQuota\sExceeded|You\shave\s\(\d+\)\sunreceived\semails\,\sget\sit\snow|Secure\sAccount\sNotice|email\saccount\sis\snearly\sfull|Suspesious\sActivity|Your\saccess\shas\sbeen\slimited|Documents\sfrom\s[a-z0-9.\-]+\.[a-z0-9.\-]+\sService|Reminder:\sYour\saccount\shas\sbeen\sdisabled\.|Confirm\syour\sinformations\sfor|Office\s365\supgrade\sand\ssecurity\supdate\snotification|Mail\sSession\sExpiration\sWarning|Mailbox\s[0-9]{2,3}\%\sUsed\sup|I\shave\sfull\scontrol\sof\syour\sdevice|Hackers\sknow\spassword\s|or\syour\saccount\swill\sbe\spermanently\slocked|Mandatory\sEmail\sVerification|Mailbox\sStorage\sFailure|You\shave\snew\sDocuments|\d+\sPending\sMassages|Unidentified\sSign\-in\sattempt\sprevented|contul\sdvs\.\sva\sfi\ssuspendat|Review\sAction\sFor\s[a-z0-9.\_]+\@[a-z0-9.-]+|cPanel\sis\sdelaying\s\(\d\)\sincoming\smessages|Please\skeep\sor\schange\spassword\.+|\d\sPending\sDocuments\sfor\s[a-z0-9.\_]+\@[a-z0-9.-]+|Email\sat\sRisk|REVIEW:\sEmail\sdelivery\sauthentication\s[a-z0-9.\_]+\@[a-z0-9.-]+|New\sEmail\sNotification\s\-\s[0-9]{2}[A-Z0-9]{6,7}|IT\sSupport:\sRenew\s[[:lower:][:digit:][\.\-\_]]+\@[[:lower:][:digit:][\.\-\_]]+\sLicense\sNow|[a-z]{3,20}\svirus\sdetected\s\(\d\)|pending\sincoming\s[a-z0-9.\_]+\@[a-z0-9.-]+\smails|You\shave\s\[\[\(][0-9][\}\]]\spendingmess|pendingmess\xC9\x91ges|Email\sSecurity\sAlert\s[a-z0-9.]+\@[a-z0-9.-]+\s?Authentication\sRequired|Email\sConfiguration\sfor\s[a-z0-9.]+\@[a-z0-9.-]+|^SECURITY\sUPDATE|^Mail\sAttempt\sAlert|Norton\sBlocked\sYour\sDevices\sRenew\sNow|Verify\syour\saccount\sImmediately|Email\sAccount\sSecurity\sNotification|Your\sMailbox\sin\sFull|\#\d+\sPending\sEails|P\sA\sS\sS\sW\sO\sR\sD\s+E\sX\sP\sI\sR\sA\sT\sI\sO\sN\s+N\sO\sT\sI\sC\sE|Incoming\smessages\sNot\sdeliver|Policy\sVoilation\s\!|[a-z0-9.\-]+\.[a-z0-9.\-]+\s+Sign\-in\sAlert:\sAction\sRequested\s\!+|We\sdetected\ssomething\sunusual\sabout\sa\srecent\ssign\-in|You\shave\s\(\d+\)\spending\semails|An\sError\sHas\sOccured\sat\s\“.*\”/;

return();
}

sub encased1    {
    ($target) = @_;
    $output = () = $target =~ /\xF0\x9F\x84\x80|\xF0\x9F\x84\x81|\xF0\x9F\x84\x82|\xF0\x9F\x84\x83|\xF0\x9F\x84\x84|\xF0\x9F\x84\x85|\xF0\x9F\x84\x86|\xF0\x9F\x84\x87|\xF0\x9F\x84\x88|\xF0\x9F\x84\x89|\xF0\x9F\x84\x8A|\xF0\x9F\x84\x8B|\xF0\x9F\x84\x8C|\xF0\x9F\x84\x8D|\xF0\x9F\x84\x8E|\xF0\x9F\x84\x8F|\xF0\x9F\x84\x90|\xF0\x9F\x84\x91|\xF0\x9F\x84\x92|\xF0\x9F\x84\x93|\xF0\x9F\x84\x94|\xF0\x9F\x84\x95|\xF0\x9F\x84\x96|\xF0\x9F\x84\x97|\xF0\x9F\x84\x98|\xF0\x9F\x84\x99|\xF0\x9F\x84\x9A|\xF0\x9F\x84\x9B|\xF0\x9F\x84\x9C|\xF0\x9F\x84\x9D|\xF0\x9F\x84\x9E|\xF0\x9F\x84\x9F|\xF0\x9F\x84\xA0|\xF0\x9F\x84\xA1|\xF0\x9F\x84\xA2|\xF0\x9F\x84\xA3|\xF0\x9F\x84\xA4|\xF0\x9F\x84\xA5|\xF0\x9F\x84\xA6|\xF0\x9F\x84\xA7|\xF0\x9F\x84\xA8|\xF0\x9F\x84\xA9|\xF0\x9F\x84\xAA|\xF0\x9F\x84\xAB|\xF0\x9F\x84\xAC|\xF0\x9F\x84\xAD|\xF0\x9F\x84\xAE|\xF0\x9F\x84\xAF|\xF0\x9F\x84\xB0|\xF0\x9F\x84\xB1|\xF0\x9F\x84\xB2|\xF0\x9F\x84\xB3|\xF0\x9F\x84\xB4|\xF0\x9F\x84\xB5|\xF0\x9F\x84\xB6|\xF0\x9F\x84\xB7|\xF0\x9F\x84\xB8|\xF0\x9F\x84\xB9|\xF0\x9F\x84\xBA|\xF0\x9F\x84\xBB|\xF0\x9F\x84\xBC|\xF0\x9F\x84\xBD|\xF0\x9F\x84\xBE|\xF0\x9F\x84\xBF|\xF0\x9F\x85\x80|\xF0\x9F\x85\x81|\xF0\x9F\x85\x82|\xF0\x9F\x85\x83|\xF0\x9F\x85\x84|\xF0\x9F\x85\x85|\xF0\x9F\x85\x86|\xF0\x9F\x85\x87|\xF0\x9F\x85\x88|\xF0\x9F\x85\x89|\xF0\x9F\x85\x8A|\xF0\x9F\x85\x8B|\xF0\x9F\x85\x8C|\xF0\x9F\x85\x8D|\xF0\x9F\x85\x8E|\xF0\x9F\x85\x8F|\xF0\x9F\x85\x90|\xF0\x9F\x85\x91|\xF0\x9F\x85\x92|\xF0\x9F\x85\x93|\xF0\x9F\x85\x94|\xF0\x9F\x85\x95|\xF0\x9F\x85\x96|\xF0\x9F\x85\x97|\xF0\x9F\x85\x98|\xF0\x9F\x85\x99|\xF0\x9F\x85\x9A|\xF0\x9F\x85\x9B|\xF0\x9F\x85\x9C|\xF0\x9F\x85\x9D|\xF0\x9F\x85\x9E|\xF0\x9F\x85\x9F|\xF0\x9F\x85\xA0|\xF0\x9F\x85\xA1|\xF0\x9F\x85\xA2|\xF0\x9F\x85\xA3|\xF0\x9F\x85\xA4|\xF0\x9F\x85\xA5|\xF0\x9F\x85\xA6|\xF0\x9F\x85\xA7|\xF0\x9F\x85\xA8|\xF0\x9F\x85\xA9|\xF0\x9F\x85\xAA|\xF0\x9F\x85\xAB|\xF0\x9F\x85\xAC|\xF0\x9F\x85\xAD|\xF0\x9F\x85\xAE|\xF0\x9F\x85\xAF|\xF0\x9F\x85\xB0|\xF0\x9F\x85\xB1|\xF0\x9F\x85\xB2|\xF0\x9F\x85\xB3|\xF0\x9F\x85\xB4|\xF0\x9F\x85\xB5|\xF0\x9F\x85\xB6|\xF0\x9F\x85\xB7|\xF0\x9F\x85\xB8|\xF0\x9F\x85\xB9|\xF0\x9F\x85\xBA|\xF0\x9F\x85\xBB|\xF0\x9F\x85\xBC|\xF0\x9F\x85\xBD|\xF0\x9F\x85\xBE|\xF0\x9F\x85\xBF|\xF0\x9F\x86\x80|\xF0\x9F\x86\x81|\xF0\x9F\x86\x82|\xF0\x9F\x86\x83|\xF0\x9F\x86\x84|\xF0\x9F\x86\x85|\xF0\x9F\x86\x86|\xF0\x9F\x86\x87|\xF0\x9F\x86\x88|\xF0\x9F\x86\x89|\xF0\x9F\x86\x8A|\xF0\x9F\x86\x8B|\xF0\x9F\x86\x8C|\xF0\x9F\x86\x8D|\xF0\x9F\x86\x8E|\xF0\x9F\x86\x8F|\xF0\x9F\x86\x90|\xF0\x9F\x86\x91|\xF0\x9F\x86\x92|\xF0\x9F\x86\x93|\xF0\x9F\x86\x94|\xF0\x9F\x86\x95|\xF0\x9F\x86\x96|\xF0\x9F\x86\x97|\xF0\x9F\x86\x98|\xF0\x9F\x86\x99|\xF0\x9F\x86\x9A|\xF0\x9F\x86\x9B|\xF0\x9F\x86\x9C|\xF0\x9F\x86\x9D|\xF0\x9F\x86\x9E|\xF0\x9F\x86\x9F|\xF0\x9F\x86\xA0|\xF0\x9F\x86\xA1|\xF0\x9F\x86\xA2|\xF0\x9F\x86\xA3|\xF0\x9F\x86\xA4|\xF0\x9F\x86\xA5|\xF0\x9F\x86\xA6|\xF0\x9F\x86\xA7|\xF0\x9F\x86\xA8|\xF0\x9F\x86\xA9|\xF0\x9F\x86\xAA|\xF0\x9F\x86\xAB|\xF0\x9F\x86\xAC|\xF0\x9F\x86\xAD|\xF0\x9F\x87\xA6|\xF0\x9F\x87\xA7|\xF0\x9F\x87\xA8|\xF0\x9F\x87\xA9|\xF0\x9F\x87\xAA|\xF0\x9F\x87\xAB|\xF0\x9F\x87\xAC|\xF0\x9F\x87\xAD|\xF0\x9F\x87\xAE|\xF0\x9F\x87\xAF|\xF0\x9F\x87\xB0|\xF0\x9F\x87\xB1|\xF0\x9F\x87\xB2|\xF0\x9F\x87\xB3|\xF0\x9F\x87\xB4|\xF0\x9F\x87\xB5|\xF0\x9F\x87\xB6|\xF0\x9F\x87\xB7|\xF0\x9F\x87\xB8|\xF0\x9F\x87\xB9|\xF0\x9F\x87\xBA|\xF0\x9F\x87\xBB|\xF0\x9F\x87\xBC|\xF0\x9F\x87\xBD|\xF0\x9F\x87\xBE|\xF0\x9F\x87\xBF/g;
return($output);

}

sub encased2    {
    ($target) = @_;
    $output = () = $target =~ /\xE2\x91\xA0|\xE2\x91\xA1|\xE2\x91\xA2|\xE2\x91\xA3|\xE2\x91\xA4|\xE2\x91\xA5|\xE2\x91\xA6|\xE2\x91\xA7|\xE2\x91\xA8|\xE2\x91\xA9|\xE2\x91\xAA|\xE2\x91\xAB|\xE2\x91\xAC|\xE2\x91\xAD|\xE2\x91\xAE|\xE2\x91\xAF|\xE2\x91\xB0|\xE2\x91\xB1|\xE2\x91\xB2|\xE2\x91\xB3|\xE2\x91\xB4|\xE2\x91\xB5|\xE2\x91\xB6|\xE2\x91\xB7|\xE2\x91\xB8|\xE2\x91\xB9|\xE2\x91\xBA|\xE2\x91\xBB|\xE2\x91\xBC|\xE2\x91\xBD|\xE2\x91\xBE|\xE2\x91\xBF|\xE2\x92\x80|\xE2\x92\x81|\xE2\x92\x82|\xE2\x92\x83|\xE2\x92\x84|\xE2\x92\x85|\xE2\x92\x86|\xE2\x92\x87|\xE2\x92\x88|\xE2\x92\x89|\xE2\x92\x8A|\xE2\x92\x8B|\xE2\x92\x8C|\xE2\x92\x8D|\xE2\x92\x8E|\xE2\x92\x8F|\xE2\x92\x90|\xE2\x92\x91|\xE2\x92\x92|\xE2\x92\x93|\xE2\x92\x94|\xE2\x92\x95|\xE2\x92\x96|\xE2\x92\x97|\xE2\x92\x98|\xE2\x92\x99|\xE2\x92\x9A|\xE2\x92\x9B|\xE2\x92\x9C|\xE2\x92\x9D|\xE2\x92\x9E|\xE2\x92\x9F|\xE2\x92\xA0|\xE2\x92\xA1|\xE2\x92\xA2|\xE2\x92\xA3|\xE2\x92\xA4|\xE2\x92\xA5|\xE2\x92\xA6|\xE2\x92\xA7|\xE2\x92\xA8|\xE2\x92\xA9|\xE2\x92\xAA|\xE2\x92\xAB|\xE2\x92\xAC|\xE2\x92\xAD|\xE2\x92\xAE|\xE2\x92\xAF|\xE2\x92\xB0|\xE2\x92\xB1|\xE2\x92\xB2|\xE2\x92\xB3|\xE2\x92\xB4|\xE2\x92\xB5|\xE2\x92\xB6|\xE2\x92\xB7|\xE2\x92\xB8|\xE2\x92\xB9|\xE2\x92\xBA|\xE2\x92\xBB|\xE2\x92\xBC|\xE2\x92\xBD|\xE2\x92\xBE|\xE2\x92\xBF|\xE2\x93\x80|\xE2\x93\x81|\xE2\x93\x82|\xE2\x93\x83|\xE2\x93\x84|\xE2\x93\x85|\xE2\x93\x86|\xE2\x93\x87|\xE2\x93\x88|\xE2\x93\x89|\xE2\x93\x8A|\xE2\x93\x8B|\xE2\x93\x8C|\xE2\x93\x8D|\xE2\x93\x8E|\xE2\x93\x8F|\xE2\x93\x90|\xE2\x93\x91|\xE2\x93\x92|\xE2\x93\x93|\xE2\x93\x94|\xE2\x93\x95|\xE2\x93\x96|\xE2\x93\x97|\xE2\x93\x98|\xE2\x93\x99|\xE2\x93\x9A|\xE2\x93\x9B|\xE2\x93\x9C|\xE2\x93\x9D|\xE2\x93\x9E|\xE2\x93\x9F|\xE2\x93\xA0|\xE2\x93\xA1|\xE2\x93\xA2|\xE2\x93\xA3|\xE2\x93\xA4|\xE2\x93\xA5|\xE2\x93\xA6|\xE2\x93\xA7|\xE2\x93\xA8|\xE2\x93\xA9|\xE2\x93\xAA|\xE2\x93\xAB|\xE2\x93\xAC|\xE2\x93\xAD|\xE2\x93\xAE|\xE2\x93\xAF|\xE2\x93\xB0|\xE2\x93\xB1|\xE2\x93\xB2|\xE2\x93\xB3|\xE2\x93\xB4|\xE2\x93\xB5|\xE2\x93\xB6|\xE2\x93\xB7|\xE2\x93\xB8|\xE2\x93\xB9|\xE2\x93\xBA|\xE2\x93\xBB|\xE2\x93\xBC|\xE2\x93\xBD|\xE2\x93\xBE|\xE2\x93\xBF/g;
return($output);

}

sub mathalpha   {
    ($target) = @_;
    $output = () = $target =~ /\xF0\x9D\x90\x80|\xF0\x9D\x90\x81|\xF0\x9D\x90\x82|\xF0\x9D\x90\x83|\xF0\x9D\x90\x84|\xF0\x9D\x90\x85|\xF0\x9D\x90\x86|\xF0\x9D\x90\x87|\xF0\x9D\x90\x88|\xF0\x9D\x90\x89|\xF0\x9D\x90\x8A|\xF0\x9D\x90\x8B|\xF0\x9D\x90\x8C|\xF0\x9D\x90\x8D|\xF0\x9D\x90\x8E|\xF0\x9D\x90\x8F|\xF0\x9D\x90\x90|\xF0\x9D\x90\x91|\xF0\x9D\x90\x92|\xF0\x9D\x90\x93|\xF0\x9D\x90\x94|\xF0\x9D\x90\x95|\xF0\x9D\x90\x96|\xF0\x9D\x90\x97|\xF0\x9D\x90\x98|\xF0\x9D\x90\x99|\xF0\x9D\x90\x9A|\xF0\x9D\x90\x9B|\xF0\x9D\x90\x9C|\xF0\x9D\x90\x9D|\xF0\x9D\x90\x9E|\xF0\x9D\x90\x9F|\xF0\x9D\x90\xA0|\xF0\x9D\x90\xA1|\xF0\x9D\x90\xA2|\xF0\x9D\x90\xA3|\xF0\x9D\x90\xA4|\xF0\x9D\x90\xA5|\xF0\x9D\x90\xA6|\xF0\x9D\x90\xA7|\xF0\x9D\x90\xA8|\xF0\x9D\x90\xA9|\xF0\x9D\x90\xAA|\xF0\x9D\x90\xAB|\xF0\x9D\x90\xAC|\xF0\x9D\x90\xAD|\xF0\x9D\x90\xAE|\xF0\x9D\x90\xAF|\xF0\x9D\x90\xB0|\xF0\x9D\x90\xB1|\xF0\x9D\x90\xB2|\xF0\x9D\x90\xB3|\xF0\x9D\x90\xB4|\xF0\x9D\x90\xB5|\xF0\x9D\x90\xB6|\xF0\x9D\x90\xB7|\xF0\x9D\x90\xB8|\xF0\x9D\x90\xB9|\xF0\x9D\x90\xBA|\xF0\x9D\x90\xBB|\xF0\x9D\x90\xBC|\xF0\x9D\x90\xBD|\xF0\x9D\x90\xBE|\xF0\x9D\x90\xBF|\xF0\x9D\x91\x80|\xF0\x9D\x91\x81|\xF0\x9D\x91\x82|\xF0\x9D\x91\x83|\xF0\x9D\x91\x84|\xF0\x9D\x91\x85|\xF0\x9D\x91\x86|\xF0\x9D\x91\x87|\xF0\x9D\x91\x88|\xF0\x9D\x91\x89|\xF0\x9D\x91\x8A|\xF0\x9D\x91\x8B|\xF0\x9D\x91\x8C|\xF0\x9D\x91\x8D|\xF0\x9D\x91\x8E|\xF0\x9D\x91\x8F|\xF0\x9D\x91\x90|\xF0\x9D\x91\x91|\xF0\x9D\x91\x92|\xF0\x9D\x91\x93|\xF0\x9D\x91\x94|\xF0\x9D\x91\x95|\xF0\x9D\x91\x96|\xF0\x9D\x91\x97|\xF0\x9D\x91\x98|\xF0\x9D\x91\x99|\xF0\x9D\x91\x9A|\xF0\x9D\x91\x9B|\xF0\x9D\x91\x9C|\xF0\x9D\x91\x9D|\xF0\x9D\x91\x9E|\xF0\x9D\x91\x9F|\xF0\x9D\x91\xA0|\xF0\x9D\x91\xA1|\xF0\x9D\x91\xA2|\xF0\x9D\x91\xA3|\xF0\x9D\x91\xA4|\xF0\x9D\x91\xA5|\xF0\x9D\x91\xA6|\xF0\x9D\x91\xA7|\xF0\x9D\x91\xA8|\xF0\x9D\x91\xA9|\xF0\x9D\x91\xAA|\xF0\x9D\x91\xAB|\xF0\x9D\x91\xAC|\xF0\x9D\x91\xAD|\xF0\x9D\x91\xAE|\xF0\x9D\x91\xAF|\xF0\x9D\x91\xB0|\xF0\x9D\x91\xB1|\xF0\x9D\x91\xB2|\xF0\x9D\x91\xB3|\xF0\x9D\x91\xB4|\xF0\x9D\x91\xB5|\xF0\x9D\x91\xB6|\xF0\x9D\x91\xB7|\xF0\x9D\x91\xB8|\xF0\x9D\x91\xB9|\xF0\x9D\x91\xBA|\xF0\x9D\x91\xBB|\xF0\x9D\x91\xBC|\xF0\x9D\x91\xBD|\xF0\x9D\x91\xBE|\xF0\x9D\x91\xBF|\xF0\x9D\x92\x80|\xF0\x9D\x92\x81|\xF0\x9D\x92\x82|\xF0\x9D\x92\x83|\xF0\x9D\x92\x84|\xF0\x9D\x92\x85|\xF0\x9D\x92\x86|\xF0\x9D\x92\x87|\xF0\x9D\x92\x88|\xF0\x9D\x92\x89|\xF0\x9D\x92\x8A|\xF0\x9D\x92\x8B|\xF0\x9D\x92\x8C|\xF0\x9D\x92\x8D|\xF0\x9D\x92\x8E|\xF0\x9D\x92\x8F|\xF0\x9D\x92\x90|\xF0\x9D\x92\x91|\xF0\x9D\x92\x92|\xF0\x9D\x92\x93|\xF0\x9D\x92\x94|\xF0\x9D\x92\x95|\xF0\x9D\x92\x96|\xF0\x9D\x92\x97|\xF0\x9D\x92\x98|\xF0\x9D\x92\x99|\xF0\x9D\x92\x9A|\xF0\x9D\x92\x9B|\xF0\x9D\x92\x9C|\xF0\x9D\x92\x9D|\xF0\x9D\x92\x9E|\xF0\x9D\x92\x9F|\xF0\x9D\x92\xA0|\xF0\x9D\x92\xA1|\xF0\x9D\x92\xA2|\xF0\x9D\x92\xA3|\xF0\x9D\x92\xA4|\xF0\x9D\x92\xA5|\xF0\x9D\x92\xA6|\xF0\x9D\x92\xA7|\xF0\x9D\x92\xA8|\xF0\x9D\x92\xA9|\xF0\x9D\x92\xAA|\xF0\x9D\x92\xAB|\xF0\x9D\x92\xAC|\xF0\x9D\x92\xAD|\xF0\x9D\x92\xAE|\xF0\x9D\x92\xAF|\xF0\x9D\x92\xB0|\xF0\x9D\x92\xB1|\xF0\x9D\x92\xB2|\xF0\x9D\x92\xB3|\xF0\x9D\x92\xB4|\xF0\x9D\x92\xB5|\xF0\x9D\x92\xB6|\xF0\x9D\x92\xB7|\xF0\x9D\x92\xB8|\xF0\x9D\x92\xB9|\xF0\x9D\x92\xBA|\xF0\x9D\x92\xBB|\xF0\x9D\x92\xBC|\xF0\x9D\x92\xBD|\xF0\x9D\x92\xBE|\xF0\x9D\x92\xBF|\xF0\x9D\x93\x80|\xF0\x9D\x93\x81|\xF0\x9D\x93\x82|\xF0\x9D\x93\x83|\xF0\x9D\x93\x84|\xF0\x9D\x93\x85|\xF0\x9D\x93\x86|\xF0\x9D\x93\x87|\xF0\x9D\x93\x88|\xF0\x9D\x93\x89|\xF0\x9D\x93\x8A|\xF0\x9D\x93\x8B|\xF0\x9D\x93\x8C|\xF0\x9D\x93\x8D|\xF0\x9D\x93\x8E|\xF0\x9D\x93\x8F|\xF0\x9D\x93\x90|\xF0\x9D\x93\x91|\xF0\x9D\x93\x92|\xF0\x9D\x93\x93|\xF0\x9D\x93\x94|\xF0\x9D\x93\x95|\xF0\x9D\x93\x96|\xF0\x9D\x93\x97|\xF0\x9D\x93\x98|\xF0\x9D\x93\x99|\xF0\x9D\x93\x9A|\xF0\x9D\x93\x9B|\xF0\x9D\x93\x9C|\xF0\x9D\x93\x9D|\xF0\x9D\x93\x9E|\xF0\x9D\x93\x9F|\xF0\x9D\x93\xA0|\xF0\x9D\x93\xA1|\xF0\x9D\x93\xA2|\xF0\x9D\x93\xA3|\xF0\x9D\x93\xA4|\xF0\x9D\x93\xA5|\xF0\x9D\x93\xA6|\xF0\x9D\x93\xA7|\xF0\x9D\x93\xA8|\xF0\x9D\x93\xA9|\xF0\x9D\x93\xAA|\xF0\x9D\x93\xAB|\xF0\x9D\x93\xAC|\xF0\x9D\x93\xAD|\xF0\x9D\x93\xAE|\xF0\x9D\x93\xAF|\xF0\x9D\x93\xB0|\xF0\x9D\x93\xB1|\xF0\x9D\x93\xB2|\xF0\x9D\x93\xB3|\xF0\x9D\x93\xB4|\xF0\x9D\x93\xB5|\xF0\x9D\x93\xB6|\xF0\x9D\x93\xB7|\xF0\x9D\x93\xB8|\xF0\x9D\x93\xB9|\xF0\x9D\x93\xBA|\xF0\x9D\x93\xBB|\xF0\x9D\x93\xBC|\xF0\x9D\x93\xBD|\xF0\x9D\x93\xBE|\xF0\x9D\x93\xBF/g;
return($output);

}

sub cjkforms    {
    ($target) = @_;
    $output = () = $target =~ /\xEF\xBC\x81|\xEF\xBC\x82|\xEF\xBC\x83|\xEF\xBC\x84|\xEF\xBC\x85|\xEF\xBC\x86|\xEF\xBC\x87|\xEF\xBC\x88|\xEF\xBC\x89|\xEF\xBC\x8A|\xEF\xBC\x8B|\xEF\xBC\x8C|\xEF\xBC\x8D|\xEF\xBC\x8E|\xEF\xBC\x8F|\xEF\xBC\x90|\xEF\xBC\x91|\xEF\xBC\x92|\xEF\xBC\x93|\xEF\xBC\x94|\xEF\xBC\x95|\xEF\xBC\x96|\xEF\xBC\x97|\xEF\xBC\x98|\xEF\xBC\x99|\xEF\xBC\x9A|\xEF\xBC\x9B|\xEF\xBC\x9C|\xEF\xBC\x9D|\xEF\xBC\x9E|\xEF\xBC\x9F|\xEF\xBC\xA0|\xEF\xBC\xA1|\xEF\xBC\xA2|\xEF\xBC\xA3|\xEF\xBC\xA4|\xEF\xBC\xA5|\xEF\xBC\xA6|\xEF\xBC\xA7|\xEF\xBC\xA8|\xEF\xBC\xA9|\xEF\xBC\xAA|\xEF\xBC\xAB|\xEF\xBC\xAC|\xEF\xBC\xAD|\xEF\xBC\xAE|\xEF\xBC\xAF|\xEF\xBC\xB0|\xEF\xBC\xB1|\xEF\xBC\xB2|\xEF\xBC\xB3|\xEF\xBC\xB4|\xEF\xBC\xB5|\xEF\xBC\xB6|\xEF\xBC\xB7|\xEF\xBC\xB8|\xEF\xBC\xB9|\xEF\xBC\xBA|\xEF\xBC\xBB|\xEF\xBC\xBC|\xEF\xBC\xBD|\xEF\xBC\xBE|\xEF\xBC\xBF|\xEF\xBD\x80|\xEF\xBD\x81|\xEF\xBD\x82|\xEF\xBD\x83|\xEF\xBD\x84|\xEF\xBD\x85|\xEF\xBD\x86|\xEF\xBD\x87|\xEF\xBD\x88|\xEF\xBD\x89|\xEF\xBD\x8A|\xEF\xBD\x8B|\xEF\xBD\x8C|\xEF\xBD\x8D|\xEF\xBD\x8E|\xEF\xBD\x8F|\xEF\xBD\x90|\xEF\xBD\x91|\xEF\xBD\x92|\xEF\xBD\x93|\xEF\xBD\x94|\xEF\xBD\x95|\xEF\xBD\x96|\xEF\xBD\x97|\xEF\xBD\x98|\xEF\xBD\x99|\xEF\xBD\x9A|\xEF\xBD\x9B|\xEF\xBD\x9C|\xEF\xBD\x9D|\xEF\xBD\x9E|\xEF\xBD\x9F|\xEF\xBD\xA0|\xEF\xBD\xA1/g;
return($output);

}

sub utfgreek1   {
# GREEK1 https://www.utf8-chartable.de/unicode-utf8-table.pl?start=896&number=128&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xCE\x86|\xCE\x87|\xCE\x88|\xCE\x89|\xCE\x8A|\xCE\x8B|\xCE\x8C|\xCE\x8D|\xCE\x8E|\xCE\x8F|\xCE\x90|\xCE\x91|\xCE\x92|\xCE\x93|\xCE\x94|\xCE\x95|\xCE\x96|\xCE\x97|\xCE\x98|\xCE\x99|\xCE\x9A|\xCE\x9B|\xCE\x9C|\xCE\x9D|\xCE\x9E|\xCE\x9F|\xCE\xA0|\xCE\xA1|\xCE\xA2|\xCE\xA3|\xCE\xA4|\xCE\xA5|\xCE\xA6|\xCE\xA7|\xCE\xA8|\xCE\xA9|\xCE\xAA|\xCE\xAB|\xCE\xAC|\xCE\xAD|\xCE\xAE|\xCE\xAF|\xCE\xB0|\xCE\xB1|\xCE\xB2|\xCE\xB3|\xCE\xB4|\xCE\xB5|\xCE\xB6|\xCE\xB7|\xCE\xB8|\xCE\xB9|\xCE\xBA|\xCE\xBB|\xCE\xBC|\xCE\xBD|\xCE\xBE|\xCE\xBF|\xCF\x80|\xCF\x81|\xCF\x82|\xCF\x83|\xCF\x84|\xCF\x85|\xCF\x86|\xCF\x87|\xCF\x88|\xCF\x89|\xCF\x8A|\xCF\x8B|\xCF\x8C|\xCF\x8D|\xCF\x8E|\xCF\x8F|\xCF\x90|\xCF\x91|\xCF\x92|\xCF\x93|\xCF\x94|\xCF\x95|\xCF\x96|\xCF\x97|\xCF\x98|\xCF\x99|\xCF\x9A|\xCF\x9B|\xCF\x9C|\xCF\x9D|\xCF\x9E|\xCF\x9F|\xCF\xA0|\xCF\xA1|\xCF\xA2|\xCF\xA3|\xCF\xA4|\xCF\xA5|\xCF\xA6|\xCF\xA7|\xCF\xA8|\xCF\xA9|\xCF\xAA|\xCF\xAB|\xCF\xAC|\xCF\xAD|\xCF\xAE|\xCF\xAF|\xCF\xB0|\xCF\xB1|\xCF\xB2|\xCF\xB3|\xCF\xB4|\xCF\xB5|\xCF\xB6|\xCF\xB7|\xCF\xB8|\xCF\xB9|\xCF\xBA|\xCF\xBB|\xCF\xBC|\xCF\xBD|\xCF\xBE|\xCF\xBF/g;
return($output);

}

sub utfcyrilic1 {
# CYRILIC/COPTIC/GREEK  https://utf8-chartable.de/unicode-utf8-table.pl?start=832&number=512&names=2&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xCD\x80|\xCD\x81|\xCD\x82|\xCD\x83|\xCD\x84|\xCD\x85|\xCD\x86|\xCD\x87|\xCD\x88|\xCD\x89|\xCD\x8A|\xCD\x8B|\xCD\x8C|\xCD\x8D|\xCD\x8E|\xCD\x8F|\xCD\x90|\xCD\x91|\xCD\x92|\xCD\x93|\xCD\x94|\xCD\x95|\xCD\x96|\xCD\x97|\xCD\x98|\xCD\x99|\xCD\x9A|\xCD\x9B|\xCD\x9C|\xCD\x9D|\xCD\x9E|\xCD\x9F|\xCD\xA0|\xCD\xA1|\xCD\xA2|\xCD\xA3|\xCD\xA4|\xCD\xA5|\xCD\xA6|\xCD\xA7|\xCD\xA8|\xCD\xA9|\xCD\xAA|\xCD\xAB|\xCD\xAC|\xCD\xAD|\xCD\xAE|\xCD\xAF|\xCD\xB0|\xCD\xB1|\xCD\xB2|\xCD\xB3|\xCD\xB4|\xCD\xB5|\xCD\xB6|\xCD\xB7|\xCD\xB8|\xCD\xB9|\xCD\xBA|\xCD\xBB|\xCD\xBC|\xCD\xBD|\xCD\xBE|\xCD\xBF|\xCE\x80|\xCE\x81|\xCE\x82|\xCE\x83|\xCE\x84|\xCE\x85|\xCE\x86|\xCE\x87|\xCE\x88|\xCE\x89|\xCE\x8A|\xCE\x8B|\xCE\x8C|\xCE\x8D|\xCE\x8E|\xCE\x8F|\xCE\x90|\xCE\x91|\xCE\x92|\xCE\x93|\xCE\x94|\xCE\x95|\xCE\x96|\xCE\x97|\xCE\x98|\xCE\x99|\xCE\x9A|\xCE\x9B|\xCE\x9C|\xCE\x9D|\xCE\x9E|\xCE\x9F|\xCE\xA0|\xCE\xA1|\xCE\xA2|\xCE\xA3|\xCE\xA4|\xCE\xA5|\xCE\xA6|\xCE\xA7|\xCE\xA8|\xCE\xA9|\xCE\xAA|\xCE\xAB|\xCE\xAC|\xCE\xAD|\xCE\xAE|\xCE\xAF|\xCE\xB0|\xCE\xB1|\xCE\xB2|\xCE\xB3|\xCE\xB4|\xCE\xB5|\xCE\xB6|\xCE\xB7|\xCE\xB8|\xCE\xB9|\xCE\xBA|\xCE\xBB|\xCE\xBC|\xCE\xBD|\xCE\xBE|\xCE\xBF|\xCF\x80|\xCF\x81|\xCF\x82|\xCF\x83|\xCF\x84|\xCF\x85|\xCF\x86|\xCF\x87|\xCF\x88|\xCF\x89|\xCF\x8A|\xCF\x8B|\xCF\x8C|\xCF\x8D|\xCF\x8E|\xCF\x8F|\xCF\x90|\xCF\x91|\xCF\x92|\xCF\x93|\xCF\x94|\xCF\x95|\xCF\x96|\xCF\x97|\xCF\x98|\xCF\x99|\xCF\x9A|\xCF\x9B|\xCF\x9C|\xCF\x9D|\xCF\x9E|\xCF\x9F|\xCF\xA0|\xCF\xA1|\xCF\xA2|\xCF\xA3|\xCF\xA4|\xCF\xA5|\xCF\xA6|\xCF\xA7|\xCF\xA8|\xCF\xA9|\xCF\xAA|\xCF\xAB|\xCF\xAC|\xCF\xAD|\xCF\xAE|\xCF\xAF|\xCF\xB0|\xCF\xB1|\xCF\xB2|\xCF\xB3|\xCF\xB4|\xCF\xB5|\xCF\xB6|\xCF\xB7|\xCF\xB8|\xCF\xB9|\xCF\xBA|\xCF\xBB|\xCF\xBC|\xCF\xBD|\xCF\xBE|\xCF\xBF|\xD0\x80|\xD0\x81|\xD0\x82|\xD0\x83|\xD0\x84|\xD0\x85|\xD0\x86|\xD0\x87|\xD0\x88|\xD0\x89|\xD0\x8A|\xD0\x8B|\xD0\x8C|\xD0\x8D|\xD0\x8E|\xD0\x8F|\xD0\x90|\xD0\x91|\xD0\x92|\xD0\x93|\xD0\x94|\xD0\x95|\xD0\x96|\xD0\x97|\xD0\x98|\xD0\x99|\xD0\x9A|\xD0\x9B|\xD0\x9C|\xD0\x9D|\xD0\x9E|\xD0\x9F|\xD0\xA0|\xD0\xA1|\xD0\xA2|\xD0\xA3|\xD0\xA4|\xD0\xA5|\xD0\xA6|\xD0\xA7|\xD0\xA8|\xD0\xA9|\xD0\xAA|\xD0\xAB|\xD0\xAC|\xD0\xAD|\xD0\xAE|\xD0\xAF|\xD0\xB0|\xD0\xB1|\xD0\xB2|\xD0\xB3|\xD0\xB4|\xD0\xB5|\xD0\xB6|\xD0\xB7|\xD0\xB8|\xD0\xB9|\xD0\xBA|\xD0\xBB|\xD0\xBC|\xD0\xBD|\xD0\xBE|\xD0\xBF|\xD1\x80|\xD1\x81|\xD1\x82|\xD1\x83|\xD1\x84|\xD1\x85|\xD1\x86|\xD1\x87|\xD1\x88|\xD1\x89|\xD1\x8A|\xD1\x8B|\xD1\x8C|\xD1\x8D|\xD1\x8E|\xD1\x8F|\xD1\x90|\xD1\x91|\xD1\x92|\xD1\x93|\xD1\x94|\xD1\x95|\xD1\x96|\xD1\x97|\xD1\x98|\xD1\x99|\xD1\x9A|\xD1\x9B|\xD1\x9C|\xD1\x9D|\xD1\x9E|\xD1\x9F|\xD1\xA0|\xD1\xA1|\xD1\xA2|\xD1\xA3|\xD1\xA4|\xD1\xA5|\xD1\xA6|\xD1\xA7|\xD1\xA8|\xD1\xA9|\xD1\xAA|\xD1\xAB|\xD1\xAC|\xD1\xAD|\xD1\xAE|\xD1\xAF|\xD1\xB0|\xD1\xB1|\xD1\xB2|\xD1\xB3|\xD1\xB4|\xD1\xB5|\xD1\xB6|\xD1\xB7|\xD1\xB8|\xD1\xB9|\xD1\xBA|\xD1\xBB|\xD1\xBC|\xD1\xBD|\xD1\xBE|\xD1\xBF|\xD2\x80|\xD2\x81|\xD2\x82|\xD2\x83|\xD2\x84|\xD2\x85|\xD2\x86|\xD2\x87|\xD2\x88|\xD2\x89|\xD2\x8A|\xD2\x8B|\xD2\x8C|\xD2\x8D|\xD2\x8E|\xD2\x8F|\xD2\x90|\xD2\x91|\xD2\x92|\xD2\x93|\xD2\x94|\xD2\x95|\xD2\x96|\xD2\x97|\xD2\x98|\xD2\x99|\xD2\x9A|\xD2\x9B|\xD2\x9C|\xD2\x9D|\xD2\x9E|\xD2\x9F|\xD2\xA0|\xD2\xA1|\xD2\xA2|\xD2\xA3|\xD2\xA4|\xD2\xA5|\xD2\xA6|\xD2\xA7|\xD2\xA8|\xD2\xA9|\xD2\xAA|\xD2\xAB|\xD2\xAC|\xD2\xAD|\xD2\xAE|\xD2\xAF|\xD2\xB0|\xD2\xB1|\xD2\xB2|\xD2\xB3|\xD2\xB4|\xD2\xB5|\xD2\xB6|\xD2\xB7|\xD2\xB8|\xD2\xB9|\xD2\xBA|\xD2\xBB|\xD2\xBC|\xD2\xBD|\xD2\xBE|\xD2\xBF|\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF|\xD4\x80|\xD4\x81|\xD4\x82|\xD4\x83|\xD4\x84|\xD4\x85|\xD4\x86|\xD4\x87|\xD4\x88|\xD4\x89|\xD4\x8A|\xD4\x8B|\xD4\x8C|\xD4\x8D|\xD4\x8E|\xD4\x8F|\xD4\x90|\xD4\x91|\xD4\x92|\xD4\x93|\xD4\x94|\xD4\x95|\xD4\x96|\xD4\x97|\xD4\x98|\xD4\x99|\xD4\x9A|\xD4\x9B|\xD4\x9C|\xD4\x9D|\xD4\x9E|\xD4\x9F|\xD4\xA0|\xD4\xA1|\xD4\xA2|\xD4\xA3|\xD4\xA4|\xD4\xA5|\xD4\xA6|\xD4\xA7|\xD4\xA8|\xD4\xA9|\xD4\xAA|\xD4\xAB|\xD4\xAC|\xD4\xAD|\xD4\xAE|\xD4\xAF|\xD4\xB0|\xD4\xB1|\xD4\xB2|\xD4\xB3|\xD4\xB4|\xD4\xB5|\xD4\xB6|\xD4\xB7|\xD4\xB8|\xD4\xB9|\xD4\xBA|\xD4\xBB|\xD4\xBC|\xD4\xBD|\xD4\xBE|\xD4\xBF/g;
return($output);

}

sub utflatin_extb {
    # LATIN EXT-B https://www.utf8-chartable.de/unicode-utf8-table.pl?start=512&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xC8\x80|\xC8\x81|\xC8\x82|\xC8\x83|\xC8\x84|\xC8\x85|\xC8\x86|\xC8\x87|\xC8\x88|\xC8\x89|\xC8\x8A|\xC8\x8B|\xC8\x8C|\xC8\x8D|\xC8\x8E|\xC8\x8F|\xC8\x90|\xC8\x91|\xC8\x92|\xC8\x93|\xC8\x94|\xC8\x95|\xC8\x96|\xC8\x97|\xC8\x98|\xC8\x99|\xC8\x9A|\xC8\x9B|\xC8\x9C|\xC8\x9D|\xC8\x9E|\xC8\x9F|\xC8\xA0|\xC8\xA1|\xC8\xA2|\xC8\xA3|\xC8\xA4|\xC8\xA5|\xC8\xA6|\xC8\xA7|\xC8\xA8|\xC8\xA9|\xC8\xAA|\xC8\xAB|\xC8\xAC|\xC8\xAD|\xC8\xAE|\xC8\xAF|\xC8\xB0|\xC8\xB1|\xC8\xB2|\xC8\xB3|\xC8\xB4|\xC8\xB5|\xC8\xB6|\xC8\xB7|\xC8\xB8|\xC8\xB9|\xC8\xBA|\xC8\xBB|\xC8\xBC|\xC8\xBD|\xC8\xBE|\xC8\xBF|\xC9\x80|\xC9\x81|\xC9\x82|\xC9\x83|\xC9\x84|\xC9\x85|\xC9\x86|\xC9\x87|\xC9\x88|\xC9\x89|\xC9\x8A|\xC9\x8B|\xC9\x8C|\xC9\x8D|\xC9\x8E|\xC9\x8F|\xC9\x90|\xC9\x91|\xC9\x92|\xC9\x93|\xC9\x94|\xC9\x95|\xC9\x96|\xC9\x97|\xC9\x98|\xC9\x99|\xC9\x9A|\xC9\x9B|\xC9\x9C|\xC9\x9D|\xC9\x9E|\xC9\x9F|\xC9\xA0|\xC9\xA1|\xC9\xA2|\xC9\xA3|\xC9\xA4|\xC9\xA5|\xC9\xA6|\xC9\xA7|\xC9\xA8|\xC9\xA9|\xC9\xAA|\xC9\xAB|\xC9\xAC|\xC9\xAD|\xC9\xAE|\xC9\xAF|\xC9\xB0|\xC9\xB1|\xC9\xB2|\xC9\xB3|\xC9\xB4|\xC9\xB5|\xC9\xB6|\xC9\xB7|\xC9\xB8|\xC9\xB9|\xC9\xBA|\xC9\xBB|\xC9\xBC|\xC9\xBD|\xC9\xBE|\xC9\xBF|\xCA\x80|\xCA\x81|\xCA\x82|\xCA\x83|\xCA\x84|\xCA\x85|\xCA\x86|\xCA\x87|\xCA\x88|\xCA\x89|\xCA\x8A|\xCA\x8B|\xCA\x8C|\xCA\x8D|\xCA\x8E|\xCA\x8F|\xCA\x90|\xCA\x91|\xCA\x92|\xCA\x93|\xCA\x94|\xCA\x95|\xCA\x96|\xCA\x97|\xCA\x98|\xCA\x99|\xCA\x9A|\xCA\x9B|\xCA\x9C|\xCA\x9D|\xCA\x9E|\xCA\x9F|\xCA\xA0|\xCA\xA1|\xCA\xA2|\xCA\xA3|\xCA\xA4|\xCA\xA5|\xCA\xA6|\xCA\xA7|\xCA\xA8|\xCA\xA9|\xCA\xAA|\xCA\xAB|\xCA\xAC|\xCA\xAD|\xCA\xAE|\xCA\xAF|\xCA\xB0|\xCA\xB1|\xCA\xB2|\xCA\xB3|\xCA\xB4|\xCA\xB5|\xCA\xB6|\xCA\xB7|\xCA\xB8|\xCA\xB9|\xCA\xBA|\xCA\xBB|\xCA\xBC|\xCA\xBD|\xCA\xBE|\xCA\xBF|\xCB\x80|\xCB\x81|\xCB\x82|\xCB\x83|\xCB\x84|\xCB\x85|\xCB\x86|\xCB\x87|\xCB\x88|\xCB\x89|\xCB\x8A|\xCB\x8B|\xCB\x8C|\xCB\x8D|\xCB\x8E|\xCB\x8F|\xCB\x90|\xCB\x91|\xCB\x92|\xCB\x93|\xCB\x94|\xCB\x95|\xCB\x96|\xCB\x97|\xCB\x98|\xCB\x99|\xCB\x9A|\xCB\x9B|\xCB\x9C|\xCB\x9D|\xCB\x9E|\xCB\x9F|\xCB\xA0|\xCB\xA1|\xCB\xA2|\xCB\xA3|\xCB\xA4|\xCB\xA5|\xCB\xA6|\xCB\xA7|\xCB\xA8|\xCB\xA9|\xCB\xAA|\xCB\xAB|\xCB\xAC|\xCB\xAD|\xCB\xAE|\xCB\xAF|\xCB\xB0|\xCB\xB1|\xCB\xB2|\xCB\xB3|\xCB\xB4|\xCB\xB5|\xCB\xB6|\xCB\xB7|\xCB\xB8|\xCB\xB9|\xCB\xBA|\xCB\xBB|\xCB\xBC|\xCB\xBD|\xCB\xBE|\xCB\xBF/g;
return($output);

}

sub utf_letterlike {
    # LETTER-LIKE SYMBOLS https://www.utf8-chartable.de/unicode-utf8-table.pl?start=8448&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xE2\x84\x80|\xE2\x84\x81|\xE2\x84\x82|\xE2\x84\x83|\xE2\x84\x84|\xE2\x84\x85|\xE2\x84\x86|\xE2\x84\x87|\xE2\x84\x88|\xE2\x84\x89|\xE2\x84\x8A|\xE2\x84\x8B|\xE2\x84\x8C|\xE2\x84\x8D|\xE2\x84\x8E|\xE2\x84\x8F|\xE2\x84\x90|\xE2\x84\x91|\xE2\x84\x92|\xE2\x84\x93|\xE2\x84\x94|\xE2\x84\x95|\xE2\x84\x96|\xE2\x84\x97|\xE2\x84\x98|\xE2\x84\x99|\xE2\x84\x9A|\xE2\x84\x9B|\xE2\x84\x9C|\xE2\x84\x9D|\xE2\x84\x9E|\xE2\x84\x9F|\xE2\x84\xA0|\xE2\x84\xA1|\xE2\x84\xA2|\xE2\x84\xA3|\xE2\x84\xA4|\xE2\x84\xA5|\xE2\x84\xA6|\xE2\x84\xA7|\xE2\x84\xA8|\xE2\x84\xA9|\xE2\x84\xAA|\xE2\x84\xAB|\xE2\x84\xAC|\xE2\x84\xAD|\xE2\x84\xAE|\xE2\x84\xAF|\xE2\x84\xB0|\xE2\x84\xB1|\xE2\x84\xB2|\xE2\x84\xB3|\xE2\x84\xB4|\xE2\x84\xB5|\xE2\x84\xB6|\xE2\x84\xB7|\xE2\x84\xB8|\xE2\x84\xB9|\xE2\x84\xBA|\xE2\x84\xBB|\xE2\x84\xBC|\xE2\x84\xBD|\xE2\x84\xBE|\xE2\x84\xBF|\xE2\x85\x80|\xE2\x85\x81|\xE2\x85\x82|\xE2\x85\x83|\xE2\x85\x84|\xE2\x85\x85|\xE2\x85\x86|\xE2\x85\x87|\xE2\x85\x88|\xE2\x85\x89|\xE2\x85\x8A|\xE2\x85\x8B|\xE2\x85\x8C|\xE2\x85\x8D|\xE2\x85\x8E|\xE2\x85\x8F|\xE2\x85\x90|\xE2\x85\x91|\xE2\x85\x92|\xE2\x85\x93|\xE2\x85\x94|\xE2\x85\x95|\xE2\x85\x96|\xE2\x85\x97|\xE2\x85\x98|\xE2\x85\x99|\xE2\x85\x9A|\xE2\x85\x9B|\xE2\x85\x9C|\xE2\x85\x9D|\xE2\x85\x9E|\xE2\x85\x9F|\xE2\x85\xA0|\xE2\x85\xA1|\xE2\x85\xA2|\xE2\x85\xA3|\xE2\x85\xA4|\xE2\x85\xA5|\xE2\x85\xA6|\xE2\x85\xA7|\xE2\x85\xA8|\xE2\x85\xA9|\xE2\x85\xAA|\xE2\x85\xAB|\xE2\x85\xAC|\xE2\x85\xAD|\xE2\x85\xAE|\xE2\x85\xAF|\xE2\x85\xB0|\xE2\x85\xB1|\xE2\x85\xB2|\xE2\x85\xB3|\xE2\x85\xB4|\xE2\x85\xB5|\xE2\x85\xB6|\xE2\x85\xB7|\xE2\x85\xB8|\xE2\x85\xB9|\xE2\x85\xBA|\xE2\x85\xBB|\xE2\x85\xBC|\xE2\x85\xBD|\xE2\x85\xBE|\xE2\x85\xBF|\xE2\x86\x80|\xE2\x86\x81|\xE2\x86\x82|\xE2\x86\x83|\xE2\x86\x84|\xE2\x86\x85|\xE2\x86\x86|\xE2\x86\x87|\xE2\x86\x88|\xE2\x86\x89|\xE2\x86\x8A|\xE2\x86\x8B|\xE2\x86\x8C|\xE2\x86\x8D|\xE2\x86\x8E|\xE2\x86\x8F|\xE2\x86\x90|\xE2\x86\x91|\xE2\x86\x92|\xE2\x86\x93|\xE2\x86\x94|\xE2\x86\x95|\xE2\x86\x96|\xE2\x86\x97|\xE2\x86\x98|\xE2\x86\x99|\xE2\x86\x9A|\xE2\x86\x9B|\xE2\x86\x9C|\xE2\x86\x9D|\xE2\x86\x9E|\xE2\x86\x9F|\xE2\x86\xA0|\xE2\x86\xA1|\xE2\x86\xA2|\xE2\x86\xA3|\xE2\x86\xA4|\xE2\x86\xA5|\xE2\x86\xA6|\xE2\x86\xA7|\xE2\x86\xA8|\xE2\x86\xA9|\xE2\x86\xAA|\xE2\x86\xAB|\xE2\x86\xAC|\xE2\x86\xAD|\xE2\x86\xAE|\xE2\x86\xAF|\xE2\x86\xB0|\xE2\x86\xB1|\xE2\x86\xB2|\xE2\x86\xB3|\xE2\x86\xB4|\xE2\x86\xB5|\xE2\x86\xB6|\xE2\x86\xB7|\xE2\x86\xB8|\xE2\x86\xB9|\xE2\x86\xBA|\xE2\x86\xBB|\xE2\x86\xBC|\xE2\x86\xBD|\xE2\x86\xBE|\xE2\x86\xBF|\xE2\x87\x80|\xE2\x87\x81|\xE2\x87\x82|\xE2\x87\x83|\xE2\x87\x84|\xE2\x87\x85|\xE2\x87\x86|\xE2\x87\x87|\xE2\x87\x88|\xE2\x87\x89|\xE2\x87\x8A|\xE2\x87\x8B|\xE2\x87\x8C|\xE2\x87\x8D|\xE2\x87\x8E|\xE2\x87\x8F|\xE2\x87\x90|\xE2\x87\x91|\xE2\x87\x92|\xE2\x87\x93|\xE2\x87\x94|\xE2\x87\x95|\xE2\x87\x96|\xE2\x87\x97|\xE2\x87\x98|\xE2\x87\x99|\xE2\x87\x9A|\xE2\x87\x9B|\xE2\x87\x9C|\xE2\x87\x9D|\xE2\x87\x9E|\xE2\x87\x9F|\xE2\x87\xA0|\xE2\x87\xA1|\xE2\x87\xA2|\xE2\x87\xA3|\xE2\x87\xA4|\xE2\x87\xA5|\xE2\x87\xA6|\xE2\x87\xA7|\xE2\x87\xA8|\xE2\x87\xA9|\xE2\x87\xAA|\xE2\x87\xAB|\xE2\x87\xAC|\xE2\x87\xAD|\xE2\x87\xAE|\xE2\x87\xAF|\xE2\x87\xB0|\xE2\x87\xB1|\xE2\x87\xB2|\xE2\x87\xB3|\xE2\x87\xB4|\xE2\x87\xB5|\xE2\x87\xB6|\xE2\x87\xB7|\xE2\x87\xB8|\xE2\x87\xB9|\xE2\x87\xBA|\xE2\x87\xBB|\xE2\x87\xBC|\xE2\x87\xBD|\xE2\x87\xBE|\xE2\x87\xBF/g;
return($output);

}

sub utflatin_sup {
    # LATIN SUPPLEMENT https://www.utf8-chartable.de/unicode-utf8-table.pl?start=128&number=128&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xC2\xA0|\xC2\xA1|\xC2\xA2|\xC2\xA3|\xC2\xA4|\xC2\xA5|\xC2\xA6|\xC2\xA7|\xC2\xA8|\xC2\xA9|\xC2\xAA|\xC2\xAB|\xC2\xAC|\xC2\xAD|\xC2\xAE|\xC2\xAF|\xC2\xB0|\xC2\xB1|\xC2\xB2|\xC2\xB3|\xC2\xB4|\xC2\xB5|\xC2\xB6|\xC2\xB7|\xC2\xB8|\xC2\xB9|\xC2\xBA|\xC2\xBB|\xC2\xBC|\xC2\xBD|\xC2\xBE|\xC2\xBF|\xC3\x80|\xC3\x81|\xC3\x82|\xC3\x83|\xC3\x84|\xC3\x85|\xC3\x86|\xC3\x87|\xC3\x88|\xC3\x89|\xC3\x8A|\xC3\x8B|\xC3\x8C|\xC3\x8D|\xC3\x8E|\xC3\x8F|\xC3\x90|\xC3\x91|\xC3\x92|\xC3\x93|\xC3\x94|\xC3\x95|\xC3\x96|\xC3\x97|\xC3\x98|\xC3\x99|\xC3\x9A|\xC3\x9B|\xC3\x9C|\xC3\x9D|\xC3\x9E|\xC3\x9F|\xC3\xA0|\xC3\xA1|\xC3\xA2|\xC3\xA3|\xC3\xA4|\xC3\xA5|\xC3\xA6|\xC3\xA7|\xC3\xA8|\xC3\xA9|\xC3\xAA|\xC3\xAB|\xC3\xAC|\xC3\xAD|\xC3\xAE|\xC3\xAF|\xC3\xB0|\xC3\xB1|\xC3\xB2|\xC3\xB3|\xC3\xB4|\xC3\xB5|\xC3\xB6|\xC3\xB7|\xC3\xB8|\xC3\xB9|\xC3\xBA|\xC3\xBB|\xC3\xBC|\xC3\xBD|\xC3\xBE|\xC3\xBF/g;
return($output);

}   

sub utflatin_exta {
    # LATIN EXT-A https://www.utf8-chartable.de/unicode-utf8-table.pl?start=256&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xC4\x80|\xC4\x81|\xC4\x82|\xC4\x83|\xC4\x84|\xC4\x85|\xC4\x86|\xC4\x87|\xC4\x88|\xC4\x89|\xC4\x8A|\xC4\x8B|\xC4\x8C|\xC4\x8D|\xC4\x8E|\xC4\x8F|\xC4\x90|\xC4\x91|\xC4\x92|\xC4\x93|\xC4\x94|\xC4\x95|\xC4\x96|\xC4\x97|\xC4\x98|\xC4\x99|\xC4\x9A|\xC4\x9B|\xC4\x9C|\xC4\x9D|\xC4\x9E|\xC4\x9F|\xC4\xA0|\xC4\xA1|\xC4\xA2|\xC4\xA3|\xC4\xA4|\xC4\xA5|\xC4\xA6|\xC4\xA7|\xC4\xA8|\xC4\xA9|\xC4\xAA|\xC4\xAB|\xC4\xAC|\xC4\xAD|\xC4\xAE|\xC4\xAF|\xC4\xB0|\xC4\xB1|\xC4\xB2|\xC4\xB3|\xC4\xB4|\xC4\xB5|\xC4\xB6|\xC4\xB7|\xC4\xB8|\xC4\xB9|\xC4\xBA|\xC4\xBB|\xC4\xBC|\xC4\xBD|\xC4\xBE|\xC4\xBF|\xC5\x80|\xC5\x81|\xC5\x82|\xC5\x83|\xC5\x84|\xC5\x85|\xC5\x86|\xC5\x87|\xC5\x88|\xC5\x89|\xC5\x8A|\xC5\x8B|\xC5\x8C|\xC5\x8D|\xC5\x8E|\xC5\x8F|\xC5\x90|\xC5\x91|\xC5\x92|\xC5\x93|\xC5\x94|\xC5\x95|\xC5\x96|\xC5\x97|\xC5\x98|\xC5\x99|\xC5\x9A|\xC5\x9B|\xC5\x9C|\xC5\x9D|\xC5\x9E|\xC5\x9F|\xC5\xA0|\xC5\xA1|\xC5\xA2|\xC5\xA3|\xC5\xA4|\xC5\xA5|\xC5\xA6|\xC5\xA7|\xC5\xA8|\xC5\xA9|\xC5\xAA|\xC5\xAB|\xC5\xAC|\xC5\xAD|\xC5\xAE|\xC5\xAF|\xC5\xB0|\xC5\xB1|\xC5\xB2|\xC5\xB3|\xC5\xB4|\xC5\xB5|\xC5\xB6|\xC5\xB7|\xC5\xB8|\xC5\xB9|\xC5\xBA|\xC5\xBB|\xC5\xBC|\xC5\xBD|\xC5\xBE|\xC5\xBF|\xC6\x80|\xC6\x81|\xC6\x82|\xC6\x83|\xC6\x84|\xC6\x85|\xC6\x86|\xC6\x87|\xC6\x88|\xC6\x89|\xC6\x8A|\xC6\x8B|\xC6\x8C|\xC6\x8D|\xC6\x8E|\xC6\x8F|\xC6\x90|\xC6\x91|\xC6\x92|\xC6\x93|\xC6\x94|\xC6\x95|\xC6\x96|\xC6\x97|\xC6\x98|\xC6\x99|\xC6\x9A|\xC6\x9B|\xC6\x9C|\xC6\x9D|\xC6\x9E|\xC6\x9F|\xC6\xA0|\xC6\xA1|\xC6\xA2|\xC6\xA3|\xC6\xA4|\xC6\xA5|\xC6\xA6|\xC6\xA7|\xC6\xA8|\xC6\xA9|\xC6\xAA|\xC6\xAB|\xC6\xAC|\xC6\xAD|\xC6\xAE|\xC6\xAF|\xC6\xB0|\xC6\xB1|\xC6\xB2|\xC6\xB3|\xC6\xB4|\xC6\xB5|\xC6\xB6|\xC6\xB7|\xC6\xB8|\xC6\xB9|\xC6\xBA|\xC6\xBB|\xC6\xBC|\xC6\xBD|\xC6\xBE|\xC6\xBF|\xC7\x80|\xC7\x81|\xC7\x82|\xC7\x83|\xC7\x84|\xC7\x85|\xC7\x86|\xC7\x87|\xC7\x88|\xC7\x89|\xC7\x8A|\xC7\x8B|\xC7\x8C|\xC7\x8D|\xC7\x8E|\xC7\x8F|\xC7\x90|\xC7\x91|\xC7\x92|\xC7\x93|\xC7\x94|\xC7\x95|\xC7\x96|\xC7\x97|\xC7\x98|\xC7\x99|\xC7\x9A|\xC7\x9B|\xC7\x9C|\xC7\x9D|\xC7\x9E|\xC7\x9F|\xC7\xA0|\xC7\xA1|\xC7\xA2|\xC7\xA3|\xC7\xA4|\xC7\xA5|\xC7\xA6|\xC7\xA7|\xC7\xA8|\xC7\xA9|\xC7\xAA|\xC7\xAB|\xC7\xAC|\xC7\xAD|\xC7\xAE|\xC7\xAF|\xC7\xB0|\xC7\xB1|\xC7\xB2|\xC7\xB3|\xC7\xB4|\xC7\xB5|\xC7\xB6|\xC7\xB7|\xC7\xB8|\xC7\xB9|\xC7\xBA|\xC7\xBB|\xC7\xBC|\xC7\xBD|\xC7\xBE|\xC7\xBF/g;
return($output);

}

sub utf_cyrilic2 {
    # CYRILLIC https://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024&number=128&names=-&utf8=string-literal
    #          https://www.utf8-chartable.de/unicode-utf8-table.pl?start=1024&names=-&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xD0\x80|\xD0\x81|\xD0\x82|\xD0\x83|\xD0\x84|\xD0\x85|\xD0\x86|\xD0\x87|\xD0\x88|\xD0\x89|\xD0\x8A|\xD0\x8B|\xD0\x8C|\xD0\x8D|\xD0\x8E|\xD0\x8F|\xD0\x90|\xD0\x91|\xD0\x92|\xD0\x93|\xD0\x94|\xD0\x95|\xD0\x96|\xD0\x97|\xD0\x98|\xD0\x99|\xD0\x9A|\xD0\x9B|\xD0\x9C|\xD0\x9D|\xD0\x9E|\xD0\x9F|\xD0\xA0|\xD0\xA1|\xD0\xA2|\xD0\xA3|\xD0\xA4|\xD0\xA5|\xD0\xA6|\xD0\xA7|\xD0\xA8|\xD0\xA9|\xD0\xAA|\xD0\xAB|\xD0\xAC|\xD0\xAD|\xD0\xAE|\xD0\xAF|\xD0\xB0|\xD0\xB1|\xD0\xB2|\xD0\xB3|\xD0\xB4|\xD0\xB5|\xD0\xB6|\xD0\xB7|\xD0\xB8|\xD0\xB9|\xD0\xBA|\xD0\xBB|\xD0\xBC|\xD0\xBD|\xD0\xBE|\xD0\xBF|\xD1\x80|\xD1\x81|\xD1\x82|\xD1\x83|\xD1\x84|\xD1\x85|\xD1\x86|\xD1\x87|\xD1\x88|\xD1\x89|\xD1\x8A|\xD1\x8B|\xD1\x8C|\xD1\x8D|\xD1\x8E|\xD1\x8F|\xD1\x90|\xD1\x91|\xD1\x92|\xD1\x93|\xD1\x94|\xD1\x95|\xD1\x96|\xD1\x97|\xD1\x98|\xD1\x99|\xD1\x9A|\xD1\x9B|\xD1\x9C|\xD1\x9D|\xD1\x9E|\xD1\x9F|\xD1\xA0|\xD1\xA1|\xD1\xA2|\xD1\xA3|\xD1\xA4|\xD1\xA5|\xD1\xA6|\xD1\xA7|\xD1\xA8|\xD1\xA9|\xD1\xAA|\xD1\xAB|\xD1\xAC|\xD1\xAD|\xD1\xAE|\xD1\xAF|\xD1\xB0|\xD1\xB1|\xD1\xB2|\xD1\xB3|\xD1\xB4|\xD1\xB5|\xD1\xB6|\xD1\xB7|\xD1\xB8|\xD1\xB9|\xD1\xBA|\xD1\xBB|\xD1\xBC|\xD1\xBD|\xD1\xBE|\xD1\xBF|\xD2\x80|\xD2\x81|\xD2\x82|\xD2\x83|\xD2\x84|\xD2\x85|\xD2\x86|\xD2\x87|\xD2\x88|\xD2\x89|\xD2\x8A|\xD2\x8B|\xD2\x8C|\xD2\x8D|\xD2\x8E|\xD2\x8F|\xD2\x90|\xD2\x91|\xD2\x92|\xD2\x93|\xD2\x94|\xD2\x95|\xD2\x96|\xD2\x97|\xD2\x98|\xD2\x99|\xD2\x9A|\xD2\x9B|\xD2\x9C|\xD2\x9D|\xD2\x9E|\xD2\x9F|\xD2\xA0|\xD2\xA1|\xD2\xA2|\xD2\xA3|\xD2\xA4|\xD2\xA5|\xD2\xA6|\xD2\xA7|\xD2\xA8|\xD2\xA9|\xD2\xAA|\xD2\xAB|\xD2\xAC|\xD2\xAD|\xD2\xAE|\xD2\xAF|\xD2\xB0|\xD2\xB1|\xD2\xB2|\xD2\xB3|\xD2\xB4|\xD2\xB5|\xD2\xB6|\xD2\xB7|\xD2\xB8|\xD2\xB9|\xD2\xBA|\xD2\xBB|\xD2\xBC|\xD2\xBD|\xD2\xBE|\xD2\xBF|\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF/g;
return($output);

}

sub utf_cyrilic3 {
    # CYRILLIC https://utf8-chartable.de/unicode-utf8-table.pl?start=1216&number=512&names=-&utf8=string-literal
    ($target) = @_;
    $output = () = $target =~ /\xD3\x80|\xD3\x81|\xD3\x82|\xD3\x83|\xD3\x84|\xD3\x85|\xD3\x86|\xD3\x87|\xD3\x88|\xD3\x89|\xD3\x8A|\xD3\x8B|\xD3\x8C|\xD3\x8D|\xD3\x8E|\xD3\x8F|\xD3\x90|\xD3\x91|\xD3\x92|\xD3\x93|\xD3\x94|\xD3\x95|\xD3\x96|\xD3\x97|\xD3\x98|\xD3\x99|\xD3\x9A|\xD3\x9B|\xD3\x9C|\xD3\x9D|\xD3\x9E|\xD3\x9F|\xD3\xA0|\xD3\xA1|\xD3\xA2|\xD3\xA3|\xD3\xA4|\xD3\xA5|\xD3\xA6|\xD3\xA7|\xD3\xA8|\xD3\xA9|\xD3\xAA|\xD3\xAB|\xD3\xAC|\xD3\xAD|\xD3\xAE|\xD3\xAF|\xD3\xB0|\xD3\xB1|\xD3\xB2|\xD3\xB3|\xD3\xB4|\xD3\xB5|\xD3\xB6|\xD3\xB7|\xD3\xB8|\xD3\xB9|\xD3\xBA|\xD3\xBB|\xD3\xBC|\xD3\xBD|\xD3\xBE|\xD3\xBF|\xD4\x80|\xD4\x81|\xD4\x82|\xD4\x83|\xD4\x84|\xD4\x85|\xD4\x86|\xD4\x87|\xD4\x88|\xD4\x89|\xD4\x8A|\xD4\x8B|\xD4\x8C|\xD4\x8D|\xD4\x8E|\xD4\x8F|\xD4\x90|\xD4\x91|\xD4\x92|\xD4\x93|\xD4\x94|\xD4\x95|\xD4\x96|\xD4\x97|\xD4\x98|\xD4\x99|\xD4\x9A|\xD4\x9B|\xD4\x9C|\xD4\x9D|\xD4\x9E|\xD4\x9F|\xD4\xA0|\xD4\xA1|\xD4\xA2|\xD4\xA3|\xD4\xA4|\xD4\xA5|\xD4\xA6|\xD4\xA7|\xD4\xA8|\xD4\xA9|\xD4\xAA|\xD4\xAB|\xD4\xAC|\xD4\xAD|\xD4\xAE|\xD4\xAF|\xD4\xB0|\xD4\xB1|\xD4\xB2|\xD4\xB3|\xD4\xB4|\xD4\xB5|\xD4\xB6|\xD4\xB7|\xD4\xB8|\xD4\xB9|\xD4\xBA|\xD4\xBB|\xD4\xBC|\xD4\xBD|\xD4\xBE|\xD4\xBF|\xD5\x80|\xD5\x81|\xD5\x82|\xD5\x83|\xD5\x84|\xD5\x85|\xD5\x86|\xD5\x87|\xD5\x88|\xD5\x89|\xD5\x8A|\xD5\x8B|\xD5\x8C|\xD5\x8D|\xD5\x8E|\xD5\x8F|\xD5\x90|\xD5\x91|\xD5\x92|\xD5\x93|\xD5\x94|\xD5\x95|\xD5\x96|\xD5\x97|\xD5\x98|\xD5\x99|\xD5\x9A|\xD5\x9B|\xD5\x9C|\xD5\x9D|\xD5\x9E|\xD5\x9F|\xD5\xA0|\xD5\xA1|\xD5\xA2|\xD5\xA3|\xD5\xA4|\xD5\xA5|\xD5\xA6|\xD5\xA7|\xD5\xA8|\xD5\xA9|\xD5\xAA|\xD5\xAB|\xD5\xAC|\xD5\xAD|\xD5\xAE|\xD5\xAF|\xD5\xB0|\xD5\xB1|\xD5\xB2|\xD5\xB3|\xD5\xB4|\xD5\xB5|\xD5\xB6|\xD5\xB7|\xD5\xB8|\xD5\xB9|\xD5\xBA|\xD5\xBB|\xD5\xBC|\xD5\xBD|\xD5\xBE|\xD5\xBF|\xD6\x80|\xD6\x81|\xD6\x82|\xD6\x83|\xD6\x84|\xD6\x85|\xD6\x86|\xD6\x87|\xD6\x88|\xD6\x89|\xD6\x8A|\xD6\x8B|\xD6\x8C|\xD6\x8D|\xD6\x8E|\xD6\x8F|\xD6\x90|\xD6\x91|\xD6\x92|\xD6\x93|\xD6\x94|\xD6\x95|\xD6\x96|\xD6\x97|\xD6\x98|\xD6\x99|\xD6\x9A|\xD6\x9B|\xD6\x9C|\xD6\x9D|\xD6\x9E|\xD6\x9F|\xD6\xA0|\xD6\xA1|\xD6\xA2|\xD6\xA3|\xD6\xA4|\xD6\xA5|\xD6\xA6|\xD6\xA7|\xD6\xA8|\xD6\xA9|\xD6\xAA|\xD6\xAB|\xD6\xAC|\xD6\xAD|\xD6\xAE|\xD6\xAF|\xD6\xB0|\xD6\xB1|\xD6\xB2|\xD6\xB3|\xD6\xB4|\xD6\xB5|\xD6\xB6|\xD6\xB7|\xD6\xB8|\xD6\xB9|\xD6\xBA|\xD6\xBB|\xD6\xBC|\xD6\xBD|\xD6\xBE|\xD6\xBF|\xD7\x80|\xD7\x81|\xD7\x82|\xD7\x83|\xD7\x84|\xD7\x85|\xD7\x86|\xD7\x87|\xD7\x88|\xD7\x89|\xD7\x8A|\xD7\x8B|\xD7\x8C|\xD7\x8D|\xD7\x8E|\xD7\x8F|\xD7\x90|\xD7\x91|\xD7\x92|\xD7\x93|\xD7\x94|\xD7\x95|\xD7\x96|\xD7\x97|\xD7\x98|\xD7\x99|\xD7\x9A|\xD7\x9B|\xD7\x9C|\xD7\x9D|\xD7\x9E|\xD7\x9F|\xD7\xA0|\xD7\xA1|\xD7\xA2|\xD7\xA3|\xD7\xA4|\xD7\xA5|\xD7\xA6|\xD7\xA7|\xD7\xA8|\xD7\xA9|\xD7\xAA|\xD7\xAB|\xD7\xAC|\xD7\xAD|\xD7\xAE|\xD7\xAF|\xD7\xB0|\xD7\xB1|\xD7\xB2|\xD7\xB3|\xD7\xB4|\xD7\xB5|\xD7\xB6|\xD7\xB7|\xD7\xB8|\xD7\xB9|\xD7\xBA|\xD7\xBB|\xD7\xBC|\xD7\xBD|\xD7\xBE|\xD7\xBF|\xD8\x80|\xD8\x81|\xD8\x82|\xD8\x83|\xD8\x84|\xD8\x85|\xD8\x86|\xD8\x87|\xD8\x88|\xD8\x89|\xD8\x8A|\xD8\x8B|\xD8\x8C|\xD8\x8D|\xD8\x8E|\xD8\x8F|\xD8\x90|\xD8\x91|\xD8\x92|\xD8\x93|\xD8\x94|\xD8\x95|\xD8\x96|\xD8\x97|\xD8\x98|\xD8\x99|\xD8\x9A|\xD8\x9B|\xD8\x9C|\xD8\x9D|\xD8\x9E|\xD8\x9F|\xD8\xA0|\xD8\xA1|\xD8\xA2|\xD8\xA3|\xD8\xA4|\xD8\xA5|\xD8\xA6|\xD8\xA7|\xD8\xA8|\xD8\xA9|\xD8\xAA|\xD8\xAB|\xD8\xAC|\xD8\xAD|\xD8\xAE|\xD8\xAF|\xD8\xB0|\xD8\xB1|\xD8\xB2|\xD8\xB3|\xD8\xB4|\xD8\xB5|\xD8\xB6|\xD8\xB7|\xD8\xB8|\xD8\xB9|\xD8\xBA|\xD8\xBB|\xD8\xBC|\xD8\xBD|\xD8\xBE|\xD8\xBF|\xD9\x80|\xD9\x81|\xD9\x82|\xD9\x83|\xD9\x84|\xD9\x85|\xD9\x86|\xD9\x87|\xD9\x88|\xD9\x89|\xD9\x8A|\xD9\x8B|\xD9\x8C|\xD9\x8D|\xD9\x8E|\xD9\x8F|\xD9\x90|\xD9\x91|\xD9\x92|\xD9\x93|\xD9\x94|\xD9\x95|\xD9\x96|\xD9\x97|\xD9\x98|\xD9\x99|\xD9\x9A|\xD9\x9B|\xD9\x9C|\xD9\x9D|\xD9\x9E|\xD9\x9F|\xD9\xA0|\xD9\xA1|\xD9\xA2|\xD9\xA3|\xD9\xA4|\xD9\xA5|\xD9\xA6|\xD9\xA7|\xD9\xA8|\xD9\xA9|\xD9\xAA|\xD9\xAB|\xD9\xAC|\xD9\xAD|\xD9\xAE|\xD9\xAF|\xD9\xB0|\xD9\xB1|\xD9\xB2|\xD9\xB3|\xD9\xB4|\xD9\xB5|\xD9\xB6|\xD9\xB7|\xD9\xB8|\xD9\xB9|\xD9\xBA|\xD9\xBB|\xD9\xBC|\xD9\xBD|\xD9\xBE|\xD9\xBF|\xDA\x80|\xDA\x81|\xDA\x82|\xDA\x83|\xDA\x84|\xDA\x85|\xDA\x86|\xDA\x87|\xDA\x88|\xDA\x89|\xDA\x8A|\xDA\x8B|\xDA\x8C|\xDA\x8D|\xDA\x8E|\xDA\x8F|\xDA\x90|\xDA\x91|\xDA\x92|\xDA\x93|\xDA\x94|\xDA\x95|\xDA\x96|\xDA\x97|\xDA\x98|\xDA\x99|\xDA\x9A|\xDA\x9B|\xDA\x9C|\xDA\x9D|\xDA\x9E|\xDA\x9F|\xDA\xA0|\xDA\xA1|\xDA\xA2|\xDA\xA3|\xDA\xA4|\xDA\xA5|\xDA\xA6|\xDA\xA7|\xDA\xA8|\xDA\xA9|\xDA\xAA|\xDA\xAB|\xDA\xAC|\xDA\xAD|\xDA\xAE|\xDA\xAF|\xDA\xB0|\xDA\xB1|\xDA\xB2|\xDA\xB3|\xDA\xB4|\xDA\xB5|\xDA\xB6|\xDA\xB7|\xDA\xB8|\xDA\xB9|\xDA\xBA|\xDA\xBB|\xDA\xBC|\xDA\xBD|\xDA\xBE|\xDA\xBF/g;
return($output);

}

sub utf_arabic1 {
    # ARABIC
    ($target) = @_;
    $output = () = $target =~ /\xD8\x80|\xD8\x81|\xD8\x82|\xD8\x83|\xD8\x84|\xD8\x85|\xD8\x86|\xD8\x87|\xD8\x88|\xD8\x89|\xD8\x8A|\xD8\x8B|\xD8\x8C|\xD8\x8D|\xD8\x8E|\xD8\x8F|\xD8\x90|\xD8\x91|\xD8\x92|\xD8\x93|\xD8\x94|\xD8\x95|\xD8\x96|\xD8\x97|\xD8\x98|\xD8\x99|\xD8\x9A|\xD8\x9B|\xD8\x9C|\xD8\x9D|\xD8\x9E|\xD8\x9F|\xD8\xA0|\xD8\xA1|\xD8\xA2|\xD8\xA3|\xD8\xA4|\xD8\xA5|\xD8\xA6|\xD8\xA7|\xD8\xA8|\xD8\xA9|\xD8\xAA|\xD8\xAB|\xD8\xAC|\xD8\xAD|\xD8\xAE|\xD8\xAF|\xD8\xB0|\xD8\xB1|\xD8\xB2|\xD8\xB3|\xD8\xB4|\xD8\xB5|\xD8\xB6|\xD8\xB7|\xD8\xB8|\xD8\xB9|\xD8\xBA|\xD8\xBB|\xD8\xBC|\xD8\xBD|\xD8\xBE|\xD8\xBF|\xD9\x80|\xD9\x81|\xD9\x82|\xD9\x83|\xD9\x84|\xD9\x85|\xD9\x86|\xD9\x87|\xD9\x88|\xD9\x89|\xD9\x8A|\xD9\x8B|\xD9\x8C|\xD9\x8D|\xD9\x8E|\xD9\x8F|\xD9\x90|\xD9\x91|\xD9\x92|\xD9\x93|\xD9\x94|\xD9\x95|\xD9\x96|\xD9\x97|\xD9\x98|\xD9\x99|\xD9\x9A|\xD9\x9B|\xD9\x9C|\xD9\x9D|\xD9\x9E|\xD9\x9F|\xD9\xA0|\xD9\xA1|\xD9\xA2|\xD9\xA3|\xD9\xA4|\xD9\xA5|\xD9\xA6|\xD9\xA7|\xD9\xA8|\xD9\xA9|\xD9\xAA|\xD9\xAB|\xD9\xAC|\xD9\xAD|\xD9\xAE|\xD9\xAF|\xD9\xB0|\xD9\xB1|\xD9\xB2|\xD9\xB3|\xD9\xB4|\xD9\xB5|\xD9\xB6|\xD9\xB7|\xD9\xB8|\xD9\xB9|\xD9\xBA|\xD9\xBB|\xD9\xBC|\xD9\xBD|\xD9\xBE|\xD9\xBF|\xDA\x80|\xDA\x81|\xDA\x82|\xDA\x83|\xDA\x84|\xDA\x85|\xDA\x86|\xDA\x87|\xDA\x88|\xDA\x89|\xDA\x8A|\xDA\x8B|\xDA\x8C|\xDA\x8D|\xDA\x8E|\xDA\x8F|\xDA\x90|\xDA\x91|\xDA\x92|\xDA\x93|\xDA\x94|\xDA\x95|\xDA\x96|\xDA\x97|\xDA\x98|\xDA\x99|\xDA\x9A|\xDA\x9B|\xDA\x9C|\xDA\x9D|\xDA\x9E|\xDA\x9F|\xDA\xA0|\xDA\xA1|\xDA\xA2|\xDA\xA3|\xDA\xA4|\xDA\xA5|\xDA\xA6|\xDA\xA7|\xDA\xA8|\xDA\xA9|\xDA\xAA|\xDA\xAB|\xDA\xAC|\xDA\xAD|\xDA\xAE|\xDA\xAF|\xDA\xB0|\xDA\xB1|\xDA\xB2|\xDA\xB3|\xDA\xB4|\xDA\xB5|\xDA\xB6|\xDA\xB7|\xDA\xB8|\xDA\xB9|\xDA\xBA|\xDA\xBB|\xDA\xBC|\xDA\xBD|\xDA\xBE|\xDA\xBF|\xDB\x80|\xDB\x81|\xDB\x82|\xDB\x83|\xDB\x84|\xDB\x85|\xDB\x86|\xDB\x87|\xDB\x88|\xDB\x89|\xDB\x8A|\xDB\x8B|\xDB\x8C|\xDB\x8D|\xDB\x8E|\xDB\x8F|\xDB\x90|\xDB\x91|\xDB\x92|\xDB\x93|\xDB\x94|\xDB\x95|\xDB\x96|\xDB\x97|\xDB\x98|\xDB\x99|\xDB\x9A|\xDB\x9B|\xDB\x9C|\xDB\x9D|\xDB\x9E|\xDB\x9F|\xDB\xA0|\xDB\xA1|\xDB\xA2|\xDB\xA3|\xDB\xA4|\xDB\xA5|\xDB\xA6|\xDB\xA7|\xDB\xA8|\xDB\xA9|\xDB\xAA|\xDB\xAB|\xDB\xAC|\xDB\xAD|\xDB\xAE|\xDB\xAF|\xDB\xB0|\xDB\xB1|\xDB\xB2|\xDB\xB3|\xDB\xB4|\xDB\xB5|\xDB\xB6|\xDB\xB7|\xDB\xB8|\xDB\xB9|\xDB\xBA|\xDB\xBB|\xDB\xBC|\xDB\xBD|\xDB\xBE|\xDB\xBF/g;
return($output);

}

sub utf_hebrew1 {
    # HEBREW
    ($target) = @_;
    $output = () = $target =~ /\xD6\x90|\xD6\x91|\xD6\x92|\xD6\x93|\xD6\x94|\xD6\x95|\xD6\x96|\xD6\x97|\xD6\x98|\xD6\x99|\xD6\x9A|\xD6\x9B|\xD6\x9C|\xD6\x9D|\xD6\x9E|\xD6\x9F|\xD6\xA0|\xD6\xA1|\xD6\xA2|\xD6\xA3|\xD6\xA4|\xD6\xA5|\xD6\xA6|\xD6\xA7|\xD6\xA8|\xD6\xA9|\xD6\xAA|\xD6\xAB|\xD6\xAC|\xD6\xAD|\xD6\xAE|\xD6\xAF|\xD6\xB0|\xD6\xB1|\xD6\xB2|\xD6\xB3|\xD6\xB4|\xD6\xB5|\xD6\xB6|\xD6\xB7|\xD6\xB8|\xD6\xB9|\xD6\xBA|\xD6\xBB|\xD6\xBC|\xD6\xBD|\xD6\xBE|\xD6\xBF|\xD7\x80|\xD7\x81|\xD7\x82|\xD7\x83|\xD7\x84|\xD7\x85|\xD7\x86|\xD7\x87|\xD7\x88|\xD7\x89|\xD7\x8A|\xD7\x8B|\xD7\x8C|\xD7\x8D|\xD7\x8E|\xD7\x8F|\xD7\x90|\xD7\x91|\xD7\x92|\xD7\x93|\xD7\x94|\xD7\x95|\xD7\x96|\xD7\x97|\xD7\x98|\xD7\x99|\xD7\x9A|\xD7\x9B|\xD7\x9C|\xD7\x9D|\xD7\x9E|\xD7\x9F|\xD7\xA0|\xD7\xA1|\xD7\xA2|\xD7\xA3|\xD7\xA4|\xD7\xA5|\xD7\xA6|\xD7\xA7|\xD7\xA8|\xD7\xA9|\xD7\xAA|\xD7\xAB|\xD7\xAC|\xD7\xAD|\xD7\xAE|\xD7\xAF|\xD7\xB0|\xD7\xB1|\xD7\xB2|\xD7\xB3|\xD7\xB4|\xD7\xB5|\xD7\xB6|\xD7\xB7|\xD7\xB8|\xD7\xB9|\xD7\xBA|\xD7\xBB|\xD7\xBC|\xD7\xBD|\xD7\xBE|\xD7\xBF|\xD8\x80|\xD8\x81|\xD8\x82|\xD8\x83|\xD8\x84|\xD8\x85|\xD8\x86|\xD8\x87|\xD8\x88|\xD8\x89|\xD8\x8A|\xD8\x8B|\xD8\x8C|\xD8\x8D|\xD8\x8E|\xD8\x8F|\xD8\x90|\xD8\x91|\xD8\x92|\xD8\x93|\xD8\x94|\xD8\x95|\xD8\x96|\xD8\x97|\xD8\x98|\xD8\x99|\xD8\x9A|\xD8\x9B|\xD8\x9C|\xD8\x9D|\xD8\x9E|\xD8\x9F|\xD8\xA0|\xD8\xA1|\xD8\xA2|\xD8\xA3|\xD8\xA4|\xD8\xA5|\xD8\xA6|\xD8\xA7|\xD8\xA8|\xD8\xA9|\xD8\xAA|\xD8\xAB|\xD8\xAC|\xD8\xAD|\xD8\xAE|\xD8\xAF|\xD8\xB0|\xD8\xB1|\xD8\xB2|\xD8\xB3|\xD8\xB4|\xD8\xB5|\xD8\xB6|\xD8\xB7|\xD8\xB8|\xD8\xB9|\xD8\xBA|\xD8\xBB|\xD8\xBC|\xD8\xBD|\xD8\xBE|\xD8\xBF|\xD9\x80|\xD9\x81|\xD9\x82|\xD9\x83|\xD9\x84|\xD9\x85|\xD9\x86|\xD9\x87|\xD9\x88|\xD9\x89|\xD9\x8A|\xD9\x8B|\xD9\x8C|\xD9\x8D|\xD9\x8E|\xD9\x8F|\xD9\x90|\xD9\x91|\xD9\x92|\xD9\x93|\xD9\x94|\xD9\x95|\xD9\x96|\xD9\x97|\xD9\x98|\xD9\x99|\xD9\x9A|\xD9\x9B|\xD9\x9C|\xD9\x9D|\xD9\x9E|\xD9\x9F|\xD9\xA0|\xD9\xA1|\xD9\xA2|\xD9\xA3|\xD9\xA4|\xD9\xA5|\xD9\xA6|\xD9\xA7|\xD9\xA8|\xD9\xA9|\xD9\xAA|\xD9\xAB|\xD9\xAC|\xD9\xAD|\xD9\xAE|\xD9\xAF|\xD9\xB0|\xD9\xB1|\xD9\xB2|\xD9\xB3|\xD9\xB4|\xD9\xB5|\xD9\xB6|\xD9\xB7|\xD9\xB8|\xD9\xB9|\xD9\xBA|\xD9\xBB|\xD9\xBC|\xD9\xBD|\xD9\xBE|\xD9\xBF|\xDA\x80|\xDA\x81|\xDA\x82|\xDA\x83|\xDA\x84|\xDA\x85|\xDA\x86|\xDA\x87|\xDA\x88|\xDA\x89|\xDA\x8A|\xDA\x8B|\xDA\x8C|\xDA\x8D|\xDA\x8E|\xDA\x8F/g;
return($output);

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
    if ( $line =~ /([A-Za-z0-9-]{1,63}\sManagement\swould\slike\sto\sshare\san\supdate|2020\sEmail\sSecurity\.|2020\s\s\©\sAdministrator\s[a-z0-9.]+\@[a-z0-9.-]+|2020\s\©\sE\-mail\sAdmin\.|All\semail\smessages\sin\syour\spersonal\sQuarantine|Because\syou\sfailed\sto\sresolve\serrors\son\syour\semail|Blocked\s\(Important\)\sIncoming\sMessages|Click\s+below\s+and\s+follow\s+the\s+instructions\s+to\s+retain\s+your\s+email\s+account|Due\sto\sa\srecent\sconfiguration\serror\,\ssome\sof\syour\semails|Failed\sto\ssync\sand\sreturned\s\(\d\)\sincoming\smails|Follow\sbelow\sto\skeep\syour\scurrent\spassword\sand\savoid\sdata\sloss|Here\x27s\sthe\sdocument\sthat\s[a-z0-9.\-]+\.[a-z0-9.\-]+\sshared\swith\syou|IT\sDesk\s©\sCopyright\s2019|If\sdon\'t\sadd\sMB\sto\syour\smail\sbox\,\syou\swill\snot\sreceive\semails|If\syou\sare\ssure\syou\sgave\sthis\sinstruction\sfor\syour\saccount\stermination\,|If\syou\sdo\snot\scomplete\,\sthe\saccount\swill\sbe\sdeactivated\.|Kindly\sre-verify\sMailbox\sto\supdate\sMailbox\sand\sstop\stemporary\sshutdown|Kindly\sre\-login\sto\skeep\ssame\spassward\sand\sto\skeep\sit\supdated|Kindly\srelease\/view\sall\srelevant\smail\sor\sdiscard\sany\sspam\smail|Kindly\srelease\sall\srelevant\smail|Kindly\supdate\syour\semail\sto\sfix\serror\snotification\smessages|MAILBOX\sSYNCHRONIZATION\sFAILED\!|Mail\sAdmin\s\(C\)\s2020\sSecured\sService|Mail\sAdministrator\swill\salways\skeep\syou\sposted\sof\ssecurity\supdates|Mail\sCenter\sHelpdesk|Mail\sdelivery\sfailed\:You\shave\s\(\d\)\snew\sdelayed\smessages|Messages\sPending\sDelivery\sOn\sYour\se\-Mail\sPortal\sSince|Microsoft\sWebmail\ssystem|request\sto\sreset\syour\spassword\sfrom\san\sunknown\slocation\.|To\sremove\slimitations\sfrom\syour\saccount\sclick\son\sthe\sfollowing\slink|upgrade\syour\smailbox\sas\ssoon\sas\spossible|before\syour\saccess\sget\ssuspended|mailbox\sis\sfuII|due\sto\supdated\sin\sour\ssystem|We\sdiscovered\sunusual\sactivities\son\syour\saccount\.|UPGRADE\sNOW\sto\sremain\ssecured|You\sneed\senroll\sfor|INCREASE\sMAILBOX\sCAPACITY|kindly\sinstructed\s\sto\supgrade\syour\smail\saccount|update\syour\saccount\swithin\s24\sHours\sof\snotice|e\-Mail\sPassword\sCenter|[A-Z0-9.\-]+\.[A-Z0-9.\-]+\sCLOUD\sSERVICES|Webmail\ssever\sis\sholding\s\(\d\)\sincoming\smessages|you\swill\spermanently\slose\simportant\semails\sforwarded\sto\syou|Action\sRequired\sto\sfix\syour\se\-mail\ssync\serror|You\shave\sa\snew\ssecure\sIT\smessage\!|incoming\smessages\sin\syour\squarantine\sportal|Kindly\sLogon\sbelow\sto\srestore\syour\saccount|Verified\sto\sour\sSecurity\sSetting\sDatabase|Mail\s+Security\s+Service\s+have\s+temporary\s+blocked|Incoming\sEmail\sand\sOutgoing\sEmail\son\syour\sMailbox|Release\s\d+\sundelivered\svoice\smessage|It\soccured\snot\sbe\sdelivered\sat\sthe\stime\sof\ssend|We\sdetected\ssomething\sunusual\sabout\sa\srecent\ssign\-in\sto\syour\se-mail|new\smessages\shave\sbeen\srejected\sdue\sto\sa\sserver\serror\sin\sthe\s.*\sdisk\sstorage)/g ) {
        $count++;
    }
return($count);
}

sub fraud_match2 {
    ($count,$line) = @_;
    if ( $line =~ /(Organization\s\:\s+administrator\s+company|Our\sserver\ssecurity\shas\sdetected\sthat\s\(\d\)\sincoming\smessages\son|PLEASE\sCONFIRM\sIF\sTHIS\sWASN\'T\s+YOU\s+by\sclicking\son\sthe\sbelow\slink|Please\sdo\snot\signore\sthis\semail\sto\savoid\syour\saccount\sclosure|Please\skindly\suse\sthe\sbutton\sbelow\sto\scontinue\swith\sthe\ssame\spassword|Please\sre\-validate\syour\smail\sserver\swithin\s24\shours|RESULT\sTO\sTERMINATION\/DELETE|Receive\sDelayed\sMessages|Reconfirm\sOwnership\sto\skeep\syour\saccount\sactive|Server\sEmail\sService\sSecurity\.|Some\sof\syour\smails\shas\sbeen\sput\son\shold|Source:\sAdministrator\sSupport|Source\:\s[a-zA-Z0-9.\-]+\.[a-zA-Z0-9.\-]+\sSupport|Synchronize\sMail\sError|The\sAccount\sTeam\s+tbi\.net|The\sunreceived\semails\swill\sbe\sdeleted\sfrom\sthe\sserver\swithin|This\smay\salso\scause\saccount\sto\slost\simportant\smails\sif\signored|This\swas\scaused\sdue\sto\sa\ssystem\sfailure|To\scontinue\susing\s[a-z0-9.]+\@[a-z0-9.-]+\s\,\skindly\sverify\sownership|Unable\sto\ssynchronize\s\[\d\]\sincomming\smails\sto\syour\saccount|Unable\sto\ssynchronize\s\[\d\]\sincomming\smails\sto\syour\saccount|Upgrade\sMailbox\sQouta|Use\sthe\sbutton\sbelow\sto\scontinue\swith\ssame\spassword|We\sdetected\sa\ssynchronization\serror\son\syour\saccount\spending\s\d\sincoming\smessages|We\sreceived\sa\srequest\sin\sour\sserver\sto\s+SHUTDOWN\s\syour\saccount|We\sreceived\syour\sinstructions\sto\sdelete\syour\semail\saccount\sfrom\sservice|WebHosting\(C\)\s2020\sSecured\sService|Web\sAdmin\sConfiguration\sTeam|Web\sAdmin\s\(C\)\s2020\sSecured\sService|Webmail\sSecurity\steam|You\scan\scontinue\susing\syour\scurrent\spassword\svia\sthe\slink\sbelow\s|You\shave\s\d+\sfailed\/unsent\smessages\son|Account\sIssue\.\sChanged\spassword\.|within\s72\shrs\sof\sreceiving\sthis\sautomated\smail|permanently\sdeactivate\syour\saccount|[a-zA-Z0-9.\-]+\.[a-zA-Z0-9.\-]+\sE\-mail\sdelivery\scenter|Dear\swebmail\sUser|currently\sundergoing\sserver\smaintenance\supgrade|MAIL\sBANDWIDTH\sLIMIT\sREACHED|Microsoft\sIT\sAdministrator\sfor|Due\sto\ssome\sabnormal\slogin\serrors|continue\swith\sthe\scurrent\sPassword|[0-9]\sNew\ssensitive\sdocuments\sassigned\sto\s\'\s?[A-Z0-9.]+\@[A-Z0-9.-]+\s?\'|Please\skeep\sor\schange\spassword\.+|Use\sthe\sbutton\sbelow\sto\skeep\susing\syour\spassword|n\xC2\xADew\sem\xC2\xADai\xC2\xADls|UPDATE\syour\semail\sto\s2021\sVersion|your\saccount\sneeds\svaldiation|Please\sdownload\sthe\sattached\saccount\supdate\sfile\sand\slog\sinto\sthe\sfile|to\savoid\sbeing\sCompromised\sand|respond\s+is\s+not\s+gotten|to\savoid\sthis\,\squickly\sfill\sthe\sform\sbelow|upgrade\syour\smailbox\ssize\sby\supgrading\sto\sunlimited|resolve\sissue\sand\srelease\spending\smessages|[a-z0-9.\-]+\.[a-z0-9.\-]+\s+Sign\-in\sAlert\:\sAction\sRequested|review\syour\srecent\sactivity\sto\ssecure\syour\se-mail\sfrom\ssuspension|Kindly\scomplete\syour\saccount\supdate\sprocess\son\sour\swebpage\slink\sbelow|emails\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\sthat\sh\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8Fas\sbeen\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\sprev\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8Fented\sf\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8From\syou\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8F\xE2\x80\x8Fr\sinbox)/g ) {
        $count++;
    }
return($count);
}

sub fraud_match3 {
    ($count,$line) = @_;
    if ( $line =~ /(You\shave\s\d\squarantined\smessages\sin\syour\squarantine\smessage\sportal|Your\sAccount\sPassword\sis\sdue\sfor\sexpiration\sYesterday|Your\semail\s.(with\s)?[A-Za-z0-9]+\.[A-Za-z0-9]+\shas\sreached\san\supgrade\sstage|Your\semail\saddress\s[a-z0-9.]+\@[a-z0-9.-]+\shas\sbeen\sOutdated|Your\semail\sstorage\slimits\shas\sreached|Your\smessages\sare\snow\squeued\sup\sand\spending\sdelivery|Your\spassword\shas\sExpired\sCLICK\sHERE\s\sTo\sVerify|[a-z0-9.]+\@[a-z0-9.-]+\s+Online\s+Office|[a-z0-9.]+\@[a-z0-9.-]+\sDe\-activation\sNotice|[a-z0-9.]+\@[a-z0-9.-]+\sMail\sAdmin|[a-z0-9.]+\@[a-z0-9.-]+\sOnline\sMaintenance\sPortal|[a-z0-9.]+\@[a-z0-9.-]+\sSupport\sTeam|[a-z0-9.]+\@[a-z0-9.-]+\sWebApp\sAlert|[a-z0-9.]+\@[a-z0-9.-]+\sWebMail\sTeam|[a-z0-9.]+\@[a-z0-9.-]+\saccount\squota|[a-z0-9.]+\@[a-z0-9.-]+\ssecurity\smanagement|\@2020\sE\-mail\sverify|\b[A-Za-z0-9]+\.[A-Za-z0-9]+\sMailBox\sManagement\sCenter|\©\s2020\sAccount\sTeam|\©\sEMAIL\sINC\.\s2020|access\sincoming\smessages\sand\sto\savoid\smail\smalfunction|access\sto\syour\s\sMail\sAccount\swill\sbe\sDenied|account\swill\sbe\sOfficially\sPermanently|an\sautomated\sbehavior\sthat\sviolates\sour\sRules|click\son\sthe\sbutton\sbelow\sto\scancel\sthe\sdeactivation\srequest|closing\sall\sold\sversion\sof\stbi\.net|clustered\son\syour\scloud\sdue\sto\slow\semail\sstorage\scapacity\sdetected|confimation\sto\savoid\smail\smalfunction|disable\sthe\s\"Quota\:\:MailboxWarning\"\stype\sof\snotification|documents\shas\sbeen\sshared\swith\syou\son\s[a-z0-9._\-]+\@[a-z0-9.\-]+\sSharepoint\sStorage|download\spending\semails\sand\scontinue\sto\sreceive\semails\son\syou|Your\spassword\swill\sexpire\sin\sdays\stime\sfrom\snow|So\swe\shave\sLimited\syour\sAccount|your\saccount\ssecurity\sis\soutdated|your\saccess\shas\sbeen\slimited\.\slimited\.|IT\sHelpdesk\sSupport|new\sSecurity\sand\sUpgrade\sCheckup|RE\-VALIDATION\sREQUIRED\sTO\sUNBLOCK\sPENDING\sMAILS|We\sneed\sto\svalidate\syou\sas\sthe\sowner\sof\sthis\semail|your\spassword\sis\sdue\sfor\sexpiration|Here\'s\sthe\sNew\scontract\sdocument\sthat\s[a-z0-9._\-]+\.[a-z0-9._\-]+\sshared\swith\syou|Webmail\sServer\sCongestion|Verify\sNow\sor\srisk\slosing\syour\sEmail|your\semail\saccount\swill\snot\sbe\sable\sto\srecieve\semail\sletters|You\shave\s\(\d\)\spending\ssent\smessages\sundelivered|be\xC2\xADlow\srevi\xC2\xADew\sthem|Admin\s2020\s\|\sAll\srights\sreserved|follow\sthe\sURL\sbelow\sto\supgrade\syour\squota|your\smailbox\swill\sbe\sshutdown\sand\sall\sdata\swill\sbe\spermanently\slost|There\swas\s\d\srecent\smessages\sto|a\s+verification\s+respond\s+is\s+not|Click\shere\sto\sView\/Resend\sUndelivered\sMessages|to\savoid\saccount\stermination\s\&\sshutdown|You\shave\sNew\squarantined|Su\scuenta\sha\ssido\slimitada|And\syou\shave\s\d\spending\sincoming\semails|your\saccount\swill\sbe\sdeleted\sif\syou\sfail\sto\sverify\sas\sadvised|K\xC3\xBCrzlich\shaben\swir\sIhr\sKonto\svor\xC3\xBCbergehend\seingeschr\xC3\xA4nkt)/g ) { 
        $count++;
    }
return($count);
}

sub fraud_match4 {
    ($count,$line) = @_;
    if ( $line =~ /(due\sto\sinvalidation\sof\syour\smailbox|due\sto\ssecurity\slevel\slift\son\smail\sserver|exceeded\sits\smail\-quota\sand\sdue\sfor\supgrade|follow\sthe\ssteps\sto\sconfirm\sthat\syou\sare\sthe\svalid\saccount\sowner|has\sbeen\sused\sin\ssending\sBulk\smessage\sthis\swill\scause\syour\smailbox|if\syou\sdo\snot\scancel\sthis\srequest\syour\smail\swill\sbe\sshutdown\sshortly|kindly\sCancel\sRequest\sbelow\sto\supgrade|kindly\suse\sthe\sbelow\sto\scontinue\swith\ssame\spassword|lead\sto\sPermanent\sclosure\sof\sAccount|mailbox\sto\sbe\stemporarily\sclosed\suntil\sre-verification\sprocess|ownership\son\s[a-z0-9.]+\@[a-z0-9.-]+\sserver|problem\sverifying\syour\sidentity\swe\s|recover\sthese\smessages\sby\svalidating\syour\smailbox|release\sall\srelevant\smail\sor\sDiscard|review\syour\sundelivered\semails\sand\sautomatcally\sresend\semail\srequest|sign\sin\sNow\sto\sRelease\s+Message\son\syour\se\-Mail\sAccount|since\syou\shave\sQuarantine\snotification|stop\sthe\srequest\,\sif\sit\swas\smade\sin\serror\sor|suspended\sfrom\sthe\sonline\smaintenance\sservice\sdatabase|this\swas\scaused\sdue\sto\sa\ssystem\sdelay|to\sDeactivate\sall\sold\smail\sversions|visit\sthe\slink\sbelow\sto\srestore\saccess\syour\semail|will\sbe\sdisconnected\sfrom\ssending\sand\sreceiving\semails\sfrom\sother\susers|will\snot\sbe\sheld\sresponsible\sfor\syour\smailbox\smalfunction|you\scan\supgrade\sto\sextra\s+25GB\splan|your\smail\sto\savoid\sautomatic\sclosure\sof\syour\soutlook\smail|Anti\-Spam\sSystem\sfor|Clear\smailing\schannel\snow|You\shave\spending\sincoming\semails\sthat\syou\sare\syet\sto\sreceive|[a-z0-9.]+\@[a-z0-9.-]+\sadministrator(\'s)?\spolicy|\(C\)\s2020\ssecurity\sservices|has\sbeen\slisted\sfor\stermination\scheck\sattached\sfor\smore\sdetails|update\syour\saccount\snow\sto\sget\smore\semail\sspace\squota|webmail\sSecurity\sTeam|your\smailing\schannel\sis\scleared|[a-zA-Z0-9.\-]+\.[a-z0-9.\-]+\sE\-mail\sSync\sFailure\.|©\s20[0-9]{2}\sWEBMAIL\sAccounts|e\-mail\saccount\swill\sbe\sdisable\sfrom|Sign\sin\sto\sAccess\sUpgrade|password\sexpires\sTODAY|To\sapply\sthese\ssecurity\sfeatures\sclick\son\sbelow|Microsoft\sFailure\sDelivery\sNotice\.|Click\shere\sto\sview\sundelivered\ssent\semail|Fol\xC2\xADlow\sthe\sl\xC2\xADin\xC2\xADk|Someone\sfrom\syour\scontact\sshared\sa\sfile\swith\syou|CLICK\sHERE\sTO\sUNBLOCK|been\ssubjected\sto\sverification\sin\sorder\sto\srestore\syour\sAccount|continue\susing\sthe\swebmail\sservice\son\scpanel|compulsory\swebmail\sserver\sreconfiguration\sprocess|You\sreceived\sthis\semail\sfrom\sour\sWebmaster\sfor|For\ssecurity\spurposes\syour\saccount\swill\sbe\sdisabled|confirm\syour\sidentity\swithin\s\d+\shours|Microsoft\sAdvices\s[a-z0-9.]+\@[a-z0-9.-]+\s|Wish\sto\supgarde\/\s?cancel|Haga\sclic\sen\s\"Asegurar\smi\scuenta\"\spara\sconfirmar\ssu\sidentidad|verify\syour\semail\sbelow\sto\sconfirm\syour\saccount\sis\sstill\s+in\suse)/g ) {
        $count++;
    }
return($count);
}

sub fraud_match5 {
    ($count,$line) = @_;
    if ( $line =~ /(INCOMING\sMAILS\sPLACED\sON\sHOLD|\xC2\xA9Mailbox\.|We\sfound\s\d+\sincoming\sundelivered\semails\smostly\sfrom\syour\scontacts|avoid\stemporarily\sservice\sinterruption|awaiting\syour\saction\sto\sbe\sdelivered\sto\s\(\s+[a-z0-9.]+\@[a-z0-9.-]+|button\sbelow\sto\sFix\-Error\sNow|by\sthe\ssystem\sto\sby\snotification\sonly|IT\sHelpdesk\sService|STATUS\:\sPENDING\sMAILS|Update\sYour\sBlockchain\sHere\sNow|I\.T\sAdminnotice|Your\se\-mail\sPassword\shas\sexpired|Pdf\sfile\son\sour\ssecure\sserver\sfor\syour\sview\sonly|messages\sthat\sare\srejected\sdue\sto\sserver\serror|allow\smails\sand\sadd\sMemory|message\susing\sMicrosoft\sonedrive|This\smessage\swas\ssent\sto\s[a-z0-9.]+\@[a-z0-9.-]+\s\;\s\;|pending\smassage\sdue\sto\snetwork|Mail\swill\sbe\sdelivered\sto\syour\sinbox\safter\sclicking\srelease|We\sare\supdating\sall\smailbox\sto|to\sUpgrade\sDisk\-space\sautomatically|Click\sbelow\sto\supdate\syour\sstorage\scapacity|mailbox\scan\sno\slonger\ssend\sor\sreceive\snew\simportant\smessages|Please\sclick\son\sWeb\sAccess\sand\sfollow\sthe\sinstructions|dezactivate\sîn\stermen\sde\s24\sde\sore|an\sunexpected\serror\,\splease\sreview\sthe\smessages\sfrom\sbelow|Release\sIncoming\sMessages|Follow\sthe\slink\sbelow\sto\strack\sand\sdownload\sfinal\sdocuments\.|allow\scouple\sof\sminutes\sfor\supdate\sto\sbe\scompeleted|Review\s\&\sVerify\syour\saccount|Please\sclear\syour\smailing\schannel\simmediately|Server\sEmail\sDeactivation\sNotice\.|Do\sverify\sthe\s[a-z0-9.]+\@[a-z0-9.-]+\sin\syour\saccount|Keep\sMy\sCurrent\sPassword|the\snew\smail\sdelivery\sfeatures\sare\snot\sapplied\sto\syour\saccount\sproperly|Your\smailbox\shas\sexceeded\sits\smail\-quota\sand\sdue\sfor\supgrade|Your\smailbox\sis\sout\sof\squota\sand\swill\sreject\sall\sincoming\smails|has\sfailed\sto\sdeliver\s\[\d\]\snew\semails\sfrom\ssome\sof\syour\scontacts|[a-zA-Z0-9.\-]+\.[a-z0-9.\-]+\sUpdate\sServer\sAlert|[a-zA-Z0-9.\-]+\.[a-z0-9.\-]+\sSecurity\sTeam\!|old\sversions\sof\sOur\sMailbox|You\shave\s\d\snew\sundelivered\smessage\(s\)\sin\syour\sinbox|upgrade\syour\saccount\sto\sthe\smailbox\snew\sversion|advised\sto\sRe\-validate\syour\saccount|yo\xC2\xADur\sin\xC2\xADbo\xC2\xADx|Your\slicense\sfor\s[[:lower:][:digit:][\.\-\_]]+\@[[:lower:][:digit:][\.\-\_]]+\swill\ssoon\sexpire\sin|info\@[a-zA-Z0-9.\-]+\.[a-z0-9.\-]+\sShared\sDocs\sfile\swith\syou|K\xC2\xADe\xC2\xADep\sS\xC2\xADa\xC2\xADme\sP\xC2\xADas\xC2\xADsw\xC2\xADo\xC2\xADrd|Click\son\sUPDATE\sand\supdate\syour\saccount|\([0-9]\)\smessages\sthat\shas\sbeen\splaced\son\shold|spam\s+activities\s+from\s+your\s+mail\s+box|\d+\sfailed\ssent\smessages\sstuck\son\sserver|if\sfailure\sto\sverify\sand\sconfirm\syour\sidentity|undelivered\svoice\smessage\sfrom\syour\smail\scloud\sstorage|incoming\smessages\swhich\swas\sreturned|\(C\)\s2021\sMessage\sCenter\.)/g ) {
        $count++;
    }
return($count);
}

sub fname_match {
    $fname1 = qr/Aaron|Abe|Abel|Abigail|Abraham|Abby|Adam|Adele|Adelina|Adrian|Adriana|Adrianna|Ahmed|Aisha|Alan|Alastair|Albina|Alex|Alexa|Alexandra|Alexis|Alice|Alicia|Alina|Alinka|Alison|Allen|Allison|Allyssa|Althea|Alyson|Alyssa|Albert|Alfred|Althea|Amanda|Amelia|Amber|Amelia|Amy|Ana|Anabelle|Andrea|Andrew|Andy|Andrea|Angel|Angela|Angelique|Angelo|Anita|Ann|Anna|Annabelle|Anne|Annette|Annie|Anthony|Antoinette|Antonin|Anya|April|Arnold|Arlene|Aron|Ashley|Ashton|Aspen|Audrey|Aubrey|Auslar|Austin|Autumn|Ava|Avery|Axel|Barbara|Barney|Barry|Bartoov|Basil|Beatrice|Becky|Belinda|Belle|Ben|Benno|Benny|Benson|Bernadette|Bernard|Bernie|Berry|Bertha|Beryl|Beth|Bethany|Betty|Beulah|Beverly|Bianca|Bill(y|ie)?|Bintou|Blaine|Blair|Blake|Bob|Bobbie|Bobby|Bonnie|Boris|Brad|Bradley|Brandi|Brady|Brandon|Brayden|Brenda|Brendan|Brianna|Brent|Brett|Brian|Brianna|Brie|Britt?|Brittany|Brody|Brooke|Brooklynn|Bryan|Bryce|Buford|Caitlin|Cal|Caleb|Candace|Candice|Candy|Cara|Caren|Carie|Carl|Carla|Carlo|Carlos|Carly|Carmen|Carol|Caroline|Carolyn|Carrie|Carry|Carter|Casey|Cass|Cassandra|Catherine|Cathy|Cecelia|Cecil|Cecilia|Celine|Chad|chancery|Chantelle|Charlena|Charles|Charlie|Charlotte|Chase|Chelsea|Cherish|Cherry|Cheryl|Chester|Chet|Cheyenne|Chloe|Choi|Chris|Christina|Christine|Christopher|Cindy|Clair|Claire|Clara|Clare|Clarence|Clarice|Clarke?|Clarisse|Clarissa|Clay|Clayton|Clifton|Clyde|Cody|Colin|Collin|Connie|Conrad|Constance|Consuelo|Corey|Cory|Craig|Cruisines|Cynthia|Daisy|Dan|Dana|Danah|Daniel/i;
    $fname2 = qr/Danielle|Danny|Daphna|Daphne|Darla|Darlene|Darrell?|Darryl|Daryl|Dave|Davia|David|Dawn|Dawson|Dean|Debbie|Debby|Deborah|Debra|Delta|Denise|Dennis|Derek|Desdemona|Devin|Devon|Dexter|Diana|Diane|DHD|Dina|Dino|Dolores|Don|Donald|Donn|Donna|Donovan|Doreen|Doris|Doug|Douglas|Drew|Drone|Durham|Eddie|Eddy|Eden|Edgar|Edith|Edward|Eileen|Elaine|Elena|Elina|Elizabeth|Elizaveta|Ellen|Emma|Emmanuel|Emily|Eric|Erica|Erik|Erika|Ernest|Estelle|Ester|Ethan|Ethel|Eugene|Evan|Eve|Evelyn|Faith|Faroline|Farrah|Fatima|Faviola|Felicia|Felix|Florence|Floyd|Fluent|Francis|Frank|Franklin|Fred|Freddy|Frederick|Gabby|Gabe|Gabrella|Gabriel|Gabriella|Gadie|Gail|Garrett|Gary|Gavin|Gayle|Gaylord|Geneva|George|Georgia|Gerald|Geraldo|Gerry|Gil|Gilbert|Gilberto|Giselle|Glaucia|Gloria|Godwin|Gordon|Grace|Grant|Greco|Greg|Guillermo|Gus|Gwen|Hadi|Hal|Haley?|Hamilton|Hank|Hannah|Harold|Harry|Hazel|Heather|Heidi|Helen|Helena|Henrietta|Henry|Herk|Herm|Holly|Hollie|Hollis|Hope|Hoss|Howard|Hugo|Huiman|Ian|Imogen|Ingrid|Ira|Irene|Isabella|Israel|Ivan|Jack|Jackie|Jackson|Jacky|Jacob|Jade|Jai|Jake|James|Jamie|Jan|Jana|Janet?|Jared|Jason|Jasmine|Janet|Janice|Jason|Jay(la)?|Jean|Jeb|Jeff|Jefferson|Jeffery|Jeffrey|Jeanette|Jenn|Jenna|Jennifer|Jenny|Jeremy|Jerold|Jerry|Jess|Jesse|Jessica|Jessie|Jesus|jethro|Jill|Jillian|Jim|Jimenez|Jimmy|Joan|Joanne|Jocelyn|Jodi|Jody|Joe|Joel|Joey|Johan|John|Johnny|Johnathan|Jon|Jonathan|Jonna|Jordan|Jose|Josefin|Joseph|Josephine|Josh|Joshua|Joy|Joyce|Juan|Juanita|Judith|Judy|Juli|Julia|Juliana|Julie|Juliet|Julio|Juliya|Justin|Justine/i;
    $fname3 = qr/Kaleb|Karen|Karim|Karl|Karlie|Kasey|Kat|Kate|Katherine|Kathleen|Kathryn|Kathy|Katie|Katrina|Katy|Kay|Kayden|Kayla|Keegan|Keith|Kelly|Kelsey|Ken|Kendra|Kenneth|Kenny|Kevin|Khloe|Kim|Kimberly|Kirk|Kirsten|Klaus|Krause|Krista|Kristan|Kristen|Kristin|kristine|Kurt|Kyle|Kylie|Laarni|Lance|Lancer|Lady|Landon|Lana|Lanny|Laraine|Larisa|Larry|Lars|Latasha|Laura|Lauran|Lauren|Laurie|Lawrence|Lazaro|Leah|Lee|Leigh|Lena|Lenny|Leon|Leonardo|Leslie|Lewis|Liam|Liane|Lilia|Lilian|Lily|Linda|Lindsay|Lindsey|linmda|Lionel|Lis|Lisa|Liu|Logan|Lois|Lola|Lora|Lorraine|Lori|Lou|Louis|Louise|Lubna|Lucas|Lucy|Lucille|Luis|Luke|Lula|Luna|Lyle|Lynette|Lynn|Lyubov|Mack|Mackenzie|Madelaine|Madeline|Maggie|Madison|Malai|Malcolm|Malinda|Mallory|Mandy|Manuel|Marcel|Marco|Marcus|Marcie|Margaret|Marge|Margie|Margo|Marie|Mark|Marlene|Marley|Matt|Maria|Mariam|Marianne|Marietta|Marilyn|Mario|Marion|Marissa|Mariya|Marshall|Martha|Matias|Martin|Martina|Marvin|Mary|Marylin|Marylyn|Matt|Matthew|Mathias|Mavis|Max|Maxine|Megan|Mel|Melanie|mellanie|Melinda|Melissa|Mellisa|Melvin|Mendoza|Mercy|Meredith|Meri|Mia|Michael|Micheal|Michelle|Miguel|Mike|Miles|Millie|Milo|Minnie|Mirku|Missoula|Missula|Mitch|Mitchell|Mohammad|Molly|Monica|Monique|Monu|Moran|Morgan|Morris|Muriel|Nadia|Nadine|Nancy|Nash|Natalia|Natalie|Natasha|Nate|Nathan|Nathaniel|Naty|Ned|Nell|Nelson|Ngozi|Nicholas|Nick|Nicole|Nigel|Nina|Noah|Norbert|Norman|Olga|Oliva|Olive|Olivia|Olive|Oliver|Oxana|Page|Pam|Pamela|Pancho|Paris|Parker|Pat|Patricia|Patrick|Patti|Pattie|Patty|Paul|Paula|Pearl|Pedro|Pepe|Pete|Peter|Phil|Philips|Phillip/i;
    $fname4 = qr/Phoebe|Phyllis|Porter|Preston|Priscilla|Priya|Rachel|Ralph|Randall?|Randy|Raquel|Rashad|Rashmi|Raul|Raven|Raymond|Rebecca|Regina|Remi|Renee?|Ricardo|Rich|Richard|Rick|Ricky|Riley|Rita|Rob|Robbie|Robert|Robin|Rocco|Rocky|Roger|Roland|Rolando|Ron|Rona|Ronald|Ronnia|Rosa|Rosaline|Rosalina|Rosanne|Roscoe|Rose|Rosie|Ross|Rosy|Rowan|Roxana|Roxanne|Roy|rvsleju|Ruby|Russell|Ruth|Ryan|Sabrina|Sage|Sally|Sam|Sami|Samir|Sammy|Samantha|Sandra|Sandy|Santos|Sara|Sarah|Sarita|Saul|Savannah|Scarlett|Scotty?|Sean|Sergio|Seth|Sevgi|Shamir|Shane|Shannon|Sharon|Shaun|Shavonda|Shayla|Sheila|Shelley|Shelly|Sheri|Sherry|Shia|Shirley|Sidney|Skyler|Snow|Sofia|Sonia|Sophia|Sophie|Spencer|Stacey|Stacy|Stan|Stanley|Stef|Stella|Stephan|Stephanie|Stephen|Stephie|Stephine|Steve|Steven|Stokes|Stuart|Summer|Sung|Sunie|Sunny|Susan|Susie|Sutton|Suzanne|Suzy|Sven|Sylvia|Sydney|Tabitha|Tamara|Tammy|Tanya|Tara|Tatiana|Tawney|Taylor|Teresa|Terry|Theodore|Theresa|Thomas|Tiffany|Tim|Timothy|Tina|Todd|Tom|Tomi|Tommy|Toni|Tonia|Tony|Tonny|Tory|Tracey|Tracy|Travis|Trevor|Trieu|Tristan|Tucker|Tyrone|Ursula|Valerie|Vance|Vanessa|Vann|Vera|Veronica|Vickie|Victor|Victoria|Vincent|Violet|Viktoriya|Virginia|Vivian|Vlad|Vladimir|Vonda|Wade|Walter|Wanda|Ward|Warren|WebMed|Wendy|Wes|Wesley|Whitney|Will|William|Willie|Willis|Wilma|Wong|Woodtai|Yolanda|Yvonne|Zach|Zachary|Zainab|Zoe/i;
    $fname_plus = qr/Mr|Mrs|Ms|Miss|Sir|Engr|Engineer|Adv|Advocate|Mgr|Manager|Barrister|Solicitor|Esq|Esquire|Attorney|Prof|Professor|Sgt|Capt|Diplomat|Engr|From/i;
    
return();
}
    
    
# This ;1 is important
1;
