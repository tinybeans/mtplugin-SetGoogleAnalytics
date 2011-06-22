package MT::Plugin::SetGoogleAnalytics;

use strict;
use base qw( MT::Plugin );
use MT::Log;
use Data::Dumper;
sub doLog {
    my ($msg) = @_;     return unless defined($msg);
    my $log = MT::Log->new;
    $log->message($msg);
    $log->save or die $log->errstr;
}

my $plugin = MT::Plugin::SetGoogleAnalytics->new({
	id =>'setgoogleanalytics',
	key => __PACKAGE__,
	name => 'SetGoogleAnalytics',
	version => '0.01',
	description => 'description',
	author_name => 'mersy',
	author_link => 'http://linker.in/',
	plugin_link => 'https://github.com/mersy/mtplugin-SetGoogleAnalytics',
	doc_link => 'https://github.com/mersy/mtplugin-SetGoogleAnalytics/wiki',
	config_template=>\&config_template,
	settings => new MT::PluginSettings([
		['setanalyticsID',{Default =>''}],
	]),
	registry =>{
		callbacks =>{
			'build_page' => \&set_google_analytics,
		},
	},
});
MT->add_plugin($plugin);

sub config_template{
	my $tmpl =<<'EOT';
		<mtapp:setting id="setanalyticsID" label="Analytics ID:"><input type="text" name="setanalyticsID" id="setanalyticsID" value="<mt:var name="setanalyticsID" escape="html">" />
		</mtapp:setting>
EOT
}

sub set_google_analytics{
	my ($cb, %args) = @_;
	my $content_ref = $args{content};
	
	my $blog = $args{Blog};
    my $class = $blog->{column_values}->{class};
	my $id = $class eq 'website' ? $blog->{column_values}->{id} : $blog->{column_values}->{parent_id};
	my $w_value = $plugin->get_config_value('setanalyticsID', 'blog:'.$id);
	my $s_value = $plugin->get_config_value('setanalyticsID', 'system');
    my $getanalyticsID = defined $w_value ? $w_value : $s_value;
	my $analyticsCode =<<EOT;
<script type="text/javascript"> 
  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '$getanalyticsID']);
  _gaq.push(['_trackPageview']);
  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
</script> 
EOT

	$$content_ref =~ s!</body>!$analyticsCode</body>!;
}


1;