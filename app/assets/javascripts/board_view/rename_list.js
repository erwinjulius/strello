$(document).ready(function () {
/* Render Functions */
	var resetRenameListForm = function ($list) {
		$('.list').each(function () {
			var $dat = $(this);
			
			if ($dat.data('id') !== $list.data('id')) {
				$dat.children('.rename-list').addClass('hidden');
				$dat.children('h4').removeClass('hidden');
			}
		});
	};
	
  $('body').on('click', '.list h4', function () {
		var $target = $(event.target);
		var $form = $target.closest('.list').children('.rename-list');
		
		$target.closest('h4').addClass('hidden');
				
		$form.removeClass('hidden');
		$form.children('textarea').focus();

  });

	
	$('body').on('click', function (event) {
		var $target = $(event.target);
		var $list = $();
					
		if (
			$target.closest('.rename-list textarea').length !== 0 ||
			$target.closest('.rename-list input').length !== 0 ||
			$target.closest('.list h4').length !== 0 
		) {
			$list = $target.closest('.list');
		}
		
		resetRenameListForm($list);
	});
	
/* Submit Functions */
	$('body').on('submit', '.rename-list', function (event) {		
		var title = $(this).children('textarea').val();

		$(this).parent().children('h4').html(JST['list_title']({ title: title }));
		resetRenameListForm($());
	});
});