 $(function () {
     $('[data-toggle="datepicker"]').datepicker();

     $('.ToggledTab').each(function(){
     	if($(this).hasClass('TabOpen')){
     		$(this).slideDown(400);
     	}
     });

     $('.TabToggle').click(function(e){
     	//alert(e.target.id);
     	$('.TabToggle').each(function(){
     		//alert($(this).attr('id'));
     		if($(this).attr('id')!=e.target.id){
     			$(this).removeClass('TabActive');
     			$(this).next('.ToggledTab').slideUp(400);
     		}
     	});
     	if($(this).hasClass('TabActive')){
     		$(this).removeClass('TabActive');
     		$(this).next('.ToggledTab').slideUp(400);
     	}else{
     		$(this).addClass('TabActive');
     		$(this).next('.ToggledTab').slideDown(400);
     		var ThiId = $(this).attr('id');
     		setTimeout(function(){
     			$('html, body').animate({ scrollTop: $('#'+ThiId).offset().top-50 }, 600);
     		},400);
     	}
     });
});