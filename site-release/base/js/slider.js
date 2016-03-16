// Slider
var marlooSlider = (function() {
	slide = $('#slider .slide');
	nav = $('#slider nav');
	caption = $('#slider .caption')
	slideDelay = 10000;
	// counts slides
	var automaticSlide = null;
	var numSlides = slide.length;
	// gets current slide's index
	currentSlideIndex = $('.slide.current').index();
	if (numSlides > 1) {
		// make bottom row of slide nav buttons 
		var makeSlideButtons = (function() {
				for ( var i = 1; i <= numSlides; i++) {
					nav.append(
						$('<button>', {class: 'slideBtn'})
					);
				}
				nav.find('.slideBtn').eq(0).addClass('current');
		});
		makeSlideButtons();
		// caption fade in/out
		// used within slide transitions
		var prevSlideLeaves = (function() {
			$('.slide.current').removeClass('current');
			$('#slider nav .slideBtn.current').removeClass('current');
		});
		var nextSlideEnters = (function(){
			slide.eq(currentSlideIndex).addClass('current');
			nav.find('.slideBtn').eq(currentSlideIndex).addClass('current');
		});
		// slide transitions
		slideTransitionFwd = (function() {
			prevSlideLeaves();
			currentSlideIndex++;
			if (currentSlideIndex >= numSlides) {
				currentSlideIndex = 0;
			}
			nextSlideEnters();
			automaticSlide = setTimeout('slideTransitionFwd()', slideDelay);
			slide.eq(currentSlideIndex);
		});
		slideTransitionBkwd = (function() {
			prevSlideLeaves();
			if (currentSlideIndex <= 0) {
				currentSlideIndex = (numSlides - 1);
			}
			else {
				currentSlideIndex--;
			}
			nextSlideEnters();
			automaticSlide = setTimeout('slideTransitionFwd()', slideDelay);
		});
		// clicking the side buttons
		$('button#toggleRight').click(function() {
			clearTimeout(automaticSlide);
			slideTransitionFwd();
		});
		$('button#toggleLeft').click(function() {
			clearTimeout(automaticSlide);
			slideTransitionBkwd();
		});
		// clicking the bottom buttons
		$('#slider nav .slideBtn').click(function() {
			prevSlideLeaves();
			clearTimeout(automaticSlide);
			btnNum = $('#slider nav .slideBtn').index(this);
			currentSlideIndex = btnNum;
			nextSlideEnters();
			automaticSlide = setTimeout('slideTransitionFwd()', slideDelay);
		});
		// slide paused when hovering on caption
		caption.hover(
			function() {
				clearTimeout(automaticSlide);
			}, function() {
				automaticSlide = setTimeout('slideTransitionFwd()', slideDelay);
			}
		);
		automaticSlide = setTimeout('slideTransitionFwd()', slideDelay);
	}
	// if just 1 slide
	else {
	}
}); 

var marlooMiniSlider = (function() {
	sHeight = $('#slider').height();
	sMini = $('#slider').hasClass('mini');
	if (sHeight <= 350) {
		$('#slider').addClass('mini');
	}
	else if (sMini == true) {
		$('#slider').removeAttr('class');
	}
});

// Execute the above function
$(window).resize(function() {
	// changes CSS for mobile slider
	marlooMiniSlider();
});
$(window).load(function() {
	// sets the first on load
	$('#slider .slide').eq(0).addClass('current');
	marlooSlider();
	// changes CSS for mobile slider
	marlooMiniSlider();
});
