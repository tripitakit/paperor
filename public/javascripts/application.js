$(function() {
	$( "input:submit", ".form" ).button();
	$( "a", ".form" ).click(function() { return false; });
});

// $(function() {
// 	$("#slider_reldate").slider({
// 		value: 56,
// 		min: 7,
// 		max: 365,
// 		step: 7,
// 		slide: function(event, ui) {
// 			$("#reldate").val(ui.value);
// 		}
// 	});	
// });
// 
// $(function() {
// 	$("#slider_retmax").slider({
// 		value: 100,
// 		min: 30,
// 		max: 1000,
// 		step: 10,
// 		slide: function(event, ui) {
// 			$("#retmax").val(ui.value);
// 		}
// 	});	
// });

$(function(){
	$("#papers").charts();
});

$(function(){
	$("#total_papers").charts();
});