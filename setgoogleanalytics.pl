package MT::Plugin::SetGoogleAnalytics;

use strict;
use base qw( MT::Plugin );
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

sub option1{
	my $plugin = shift;
	my ($blog_id) =@_;
	my %plugin_param;
	
	$plugin->load_config(\%plugin_param,'blog:'.$blog_id);
	my $value = $plugin_param{setanalyticsID};
	unless($value){
		$plugin->load_config(\%plugin_param,'system');
		$value =$plugin_param{setanalyticsID};
	}
	$value;
}
sub set_google_analytics{
	my ($cb, %args) = @_;
	my $content_ref = $args{content};
	my $getanalyticsID = $plugin->option1;
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