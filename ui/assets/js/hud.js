function fillWater(procent, selector, color) {
    var el = document.querySelector("." + selector) || document.querySelector("#" + selector);
    if (!el) throw "Elementul nu exista";
    el.classList.add("fillme");
    if (!el.querySelector(".fill-water")) el.insertAdjacentHTML("beforeend", "<svg class=\"fill-water\" version=\"1.1\" xmlns=\"http:\/\/www.w3.org\/2000\/svg\" xmlns:xlink=\"http:\/\/www.w3.org\/1999\/xlink\" x=\"0px\" y=\"0px\" width=\"300px\" height=\"300px\" viewBox=\"0 0 300 300\" enable-background=\"new 0 0 300 300\" xml:space=\"preserve\">\r\n                <path fill=\"#04ACFF\" id=\"waveShape\" d=\"M300,300V2.5c0,0-0.6-0.1-1.1-0.1c0,0-25.5-2.3-40.5-2.4c-15,0-40.6,2.4-40.6,2.4\r\n              c-12.3,1.1-30.3,1.8-31.9,1.9c-2-0.1-19.7-0.8-32-1.9c0,0-25.8-2.3-40.8-2.4c-15,0-40.8,2.4-40.8,2.4c-12.3,1.1-30.4,1.8-32,1.9\r\n              c-2-0.1-20-0.8-32.2-1.9c0,0-3.1-0.3-8.1-0.7V300H300z\"><\/path>\r\n              <\/svg>");
    el.querySelector(".fill-water").setAttribute("style", "margin-top: " + (100 - procent) + "%;");
    if (color) el.querySelector("#waveShape").setAttribute("style", "fill: " + color + ";");
};
function configureBar(element, maxBlocks = 10) {
    let progressBarElement = element.getElementsByClassName("fm-progress-bar").item(0);

    // if we don't have a progress bar element, we create one then we append it to the progress bar element through DOM.
    if (progressBarElement === null) {
        progressBarElement = document.createElement("div");
        progressBarElement.className = "fm-progress-bar";

        element.appendChild(progressBarElement);
    }

    // remove all children of this progress bar element
    while (progressBarElement.firstChild) {
        progressBarElement.removeChild(progressBarElement.firstChild);
    }

    let progressBackground = document.createElement("div");
    progressBackground.className = "fm-progress-background";

    // append blocks to the bar
    for (var i = 0; i < maxBlocks; i++) {
        // create a progress bar block element
        let blockElement = document.createElement("div");
        blockElement.className = "fm-progress-block";

        progressBarElement.appendChild(blockElement);
    }

    element.appendChild(progressBackground);

    // reset the progress bar to 0%
    setBarProgress(element, 0);
}

function setBarColor(progressValue) {
    const container = document.querySelector('.fm-progress-container');
    const healthtextcol = document.querySelector('.healthenginecol');
    const blocks = document.querySelectorAll('.fm-progress-block');

    // Calculate the color values
    const startColor = [220, 20, 60];   // Red
    const endColor = [50, 205, 50]; // Green


    const red = Math.round(startColor[0] + (endColor[0] - startColor[0]) * progressValue / 100);
    const green = Math.round(startColor[1] + (endColor[1] - startColor[1]) * progressValue / 100);
    const blue = Math.round(startColor[2] + (endColor[2] - startColor[2]) * progressValue / 100);


    //const red = Math.round(255 - (progressValue * 2.55));
    //const green = Math.round(progressValue * 2.55);
    const gradientColor = `rgba(${red}, ${green}, ${blue}, 1.00)`;
    container.style.borderColor = gradientColor;
    healthtextcol.style.color = `${gradientColor} !important`;;
    blocks.forEach(block => {
        block.style.backgroundColor = gradientColor;
    });
}
function setBarProgress(element, progress) {
    let progressBarElement = element.getElementsByClassName("fm-progress-bar").item(0);

    if (progressBarElement === undefined) {
        throw new ReferenceError("no progress bar element found! have you configured this bar beforehand? use the configureBar method to do so.")
    }

    // clamp values between 0% and 100%
    progress = Math.max(0, Math.min(100, progress));

    // use clipping to control the progress bar
    progressBarElement.style = `clip-path: inset(0 ${100 - progress}% 0 0);`;
    setBarColor(progress);
}


var isHudDisplayed = true;
var speedText = ''
var circleProgress1 = new CircleProgress(".progress1");
circleProgress1.max = 100;
circleProgress1.value = 0;
circleProgress1.textFormat = "percent";

var circleProgress2 = new CircleProgress(".progress2");
circleProgress2.max = 100;
circleProgress2.value = 0;
circleProgress2.textFormat = "percent";

var circleProgress3 = new CircleProgress(".progress3");
circleProgress3.max = 100;
circleProgress3.value = 0;
circleProgress3.textFormat = "percent";

var circleProgress4 = new CircleProgress(".progress4");
circleProgress4.max = 100;
circleProgress4.value = 0;
circleProgress4.textFormat = "percent";

var circleProgress5 = new CircleProgress(".progress5");
circleProgress5.max = 100;
circleProgress5.value = 0;
circleProgress5.textFormat = "percent";

fillWater(0, "progress1", "#FF0000");
fillWater(0, "progress2", "#1166ff");
fillWater(0, "progress3", "#4efd54");
fillWater(0, "progress4", "#ffa600");
fillWater(0, "progress5", "#04d9ff");

var bar = document.getElementById("fm-bar");
var progress = 0;
configureBar(bar);


$(document).ready(function () {
    window.addEventListener('message', function (event) {
        var data = event.data;
        if (data.action == "hudtick") {
            if (data.show) {
                $(".h2o-hud-container").css("display", "none");
                $(".minimap").css("display", "none");

                isHudDisplayed = false;
                return;
            }
            $(".h2o-hud-container").css("display", "flex");
            $(".minimap").css("display", "flex");

            isHudDisplayed = true;

            circleProgress1.value = data.health - 100;
            circleProgress2.value = data.armor;
            circleProgress4.value = data.hunger;
            circleProgress5.value = data.thirst;
            if (data.inwater) {
                circleProgress3.value = data.oxygen * 10;
            }
            else {
                circleProgress3.value = data.stamina
            }

            $('.progress1').fadeIn();
            $(".progress1").css("display", 'inline-block');
            fillWater(circleProgress1.value, "progress1", "#FF0000");

            $('.progress2').fadeIn();
            $(".progress2").css("display", 'inline-block');
            fillWater(circleProgress2.value, "progress2", "#1166ff");

            $('.progress3').fadeIn();
            $(".progress3").css("display", 'inline-block');
            fillWater(circleProgress3.value, "progress3", "#4efd54");

            $('.progress4').fadeIn();
            $(".progress4").css("display", 'inline-block');
            fillWater(circleProgress4.value, "progress4", "#ffa600");

            $('.progress5').fadeIn();
            $(".progress5").css("display", 'inline-block');
            fillWater(circleProgress5.value, "progress5", "#04d9ff");

        } else if (data.action == "setValue") {
            if (data.divId || data.divId != "") {
                let info = document.getElementById(data.divId);
                if (info || info != null) {
                    info.innerHTML = data.value
                }
            }
        }

        if (data.action == "speedometertick") {
            if (data.show) {
                $("#speedometer-container").fadeOut(100)
            }
            else {
                rpm_value = data.rpm_value
                gear_value = data.gear_value
                nitro_value = data.nitro_value
                drift_available = data.drift_available
                drift_value = data.drift_value
                handbrake_value = data.handbrake_value
                brake_value = data.brake_value
                speed_value = data.speed_value
                engine_health_value = data.engine_health_value
                unit_distance_type = data.unit_distance_type
                seatbelt = data.seatbelt
                

                /*
                $("#rpmshow").css("display", "block");
                $("#nitroshow").css("display", "none");
                $(".nitrodisplay").css("display", "none");
                $(".geardisplay").css("display", "block");
                $(".speeddisplay").css("display", "block");
                $(".unitdisplay").css("display", "block");
                $(".abs").css("display", "block");
                $(".enginehealth").css("display", "flex");
                $(".healthbar").css("display", "block");
                $(".handbrake").css("display", "block");
                $(".seatbelt-info").css("display", "block");
               */
                if (typeof seatbelt !== "undefined") {
                    
                    if (seatbelt) {
                        $(".seatbelt-info img").attr("src", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQ1IDc5LjE2MzQ5OSwgMjAxOC8wOC8xMy0xNjo0MDoyMiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MTA5MzVGNjE2QjFEMTFFQTlBQ0FFNTRGMENDM0ZGOTYiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTA5MzVGNjA2QjFEMTFFQTlBQ0FFNTRGMENDM0ZGOTYiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTkgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6ODgyMkVFQjA2QUNGMTFFQTlBNjBCNjRCQURGRDJDNzgiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ODgyMkVFQjE2QUNGMTFFQTlBNjBCNjRCQURGRDJDNzgiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7U3rHfAAAl60lEQVR42uzd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");
                    }
                    else {
                        $(".seatbelt-info img").attr("src", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAgAAAAIACAYAAAD0eNT6AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuNi1jMTQ1IDc5LjE2MzQ5OSwgMjAxOC8wOC8xMy0xNjo0MDoyMiAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENDIDIwMTkgKFdpbmRvd3MpIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjg4MjJFRUIwNkFDRjExRUE5QTYwQjY0QkFERkQyQzc4IiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjg4MjJFRUIxNkFDRjExRUE5QTYwQjY0QkFERkQyQzc4Ij4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6ODgyMkVFQUU2QUNGMTFFQTlBNjBCNjRCQURGRDJDNzgiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6ODgyMkVFQUY2QUNGMTFFQTlBNjBCNjRCQURGRDJDNzgiLz4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7tMDmqAAAzn0lEQVR42uzd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");
                    }
                }

                if (typeof drift_available !== "undefined") {
                    if (drift_available) {
                        $(".drift").css("display", "block");
                    }
                    else {
                        $(".drift").css("display", "none");
                    }
                }


                if (unit_distance_type == "KMH") {
                    $(".unitdisplay").html("KM/H");
                }
                if (typeof nitro_value !== "undefined") {
                    if (nitro_value <= 0) {
                        $("#nitroshow").css("display", "none")
                        $(".nitrodisplay").css("display", "none")
                    } else {
                        $("#nitroshow").css("display", "block")
                        $(".nitrodisplay").css("display", "block")
                        $("#nitroshow").attr("data-value", nitro_value / 10)
                    }
                }


                if (typeof rpm_value !== "undefined" && typeof gear_value !== "undefined") {
                    // Vehicle RPM display
                    $("#rpmshow").attr("data-value", rpm_value.toFixed(2))

                    // Vehicle Gear display
                    if (gear_value == 0) {
                        $(".geardisplay span").html("R")
                        $(".geardisplay").attr("style", "color: rgba(255,255,255,0.5)border-color:rgba(255,255,255,0.5)")
                    } else {
                        $(".geardisplay span").html(gear_value)
                        if (rpm_value > 7.5) {
                            $(".geardisplay").attr("style", "color: rgba(235,5,61,0.5)border-color:rgba(235,5,61,.5)")
                        } else {
                            $(".geardisplay").removeAttr("style")
                        }
                    }
                }

                if (typeof speed_value !== "undefined") {
                    // Vehicle Speed Display
                    if (speed_value > 999) {
                        speed_value = 999
                    } else if (speed_value >= 100) {
                        var tmpSpeed = Math.floor(speed_value) + ''
                        speedText = '<span class="int1">' + tmpSpeed.substr(0, 1) + '</span><span class="int2">' + tmpSpeed.substr(1, 1) + '</span><span class="int3">' + tmpSpeed.substr(2, 1) + '</span>'
                    } else if (speed_value > 9 && speed_value <= 99) {
                        var tmpSpeed = Math.floor(speed_value) + ''
                        speedText = '<span class="gray int1">0</span><span class="int2">' + tmpSpeed.substr(0, 1) + '</span><span class="int3">' + tmpSpeed.substr(1, 1) + '</span>'
                    } else if (speed_value > 0 && speed_value <= 9) {
                        speedText = '<span class="gray int1">0</span><span class="gray int2">0</span><span class="int3">' + Math.floor(speed_value) + '</span>'
                    } else {
                        speedText = '<span class="gray int1">0</span><span class="gray int2">0</span><span class="gray int3">0</span>'
                    }
                    // Display speed and container
                    $(".speeddisplay").html(speedText)
                }

                if (typeof drift_value !== "undefined") {
                    // Drift
                    if (drift_value) {
                        $(".drift").html("DRIFT")
                    } else {
                        $(".drift").html('<span class="gray">DRIFT</span>')
                    }
                }

                if (typeof handbrake_value !== "undefined") {
                    // Handbrake
                    if (handbrake_value) {
                        $(".handbrake").html("HBK")
                    } else {
                        $(".handbrake").html('<span class="gray">HBK</span>')
                    }
                }
                if (typeof engine_health_value !== "undefined") {
                    setBarProgress(bar, engine_health_value)
                    if (engine_health_value != 0) {
                        $(".enginehealth").html('Engine <span class="healthenginecol"> ' + engine_health_value + '%</span>')
                    }
                }


                if (typeof brake_value !== "undefined") {
                    // Brake ABS
                    if (brake_value > 0) {
                        $(".abs").html("ABS")
                    } else {
                        $(".abs").html('<span class="gray">ABS</span>')
                    }
                }


                $("#speedometer-container").fadeIn(100)

                /*else if (data.HideHud) {
                    // Hide GUI
                    
                    $("#rpmshow").css("display", "none");
                    $("#nitroshow").css("display", "none");
                    $(".nitrodisplay").css("display", "none");
                    $(".geardisplay").css("display", "none");
                    $(".speeddisplay").css("display", "none");
                    $(".unitdisplay").css("display", "none");
                    $(".abs").css("display", "none");
                    $(".enginehealth").css("display", "none");
                    $(".healthbar").css("display", "none");
                    $(".drift").css("display", "none");
                    $(".handbrake").css("display", "none");
                    $(".seatbelt-info").css("display", "none");
                    
                    
                }*/
            }
        }
    });
})

const isHidden = elem => {
    const styles = window.getComputedStyle(elem)
    return styles.display === 'none' || styles.visibility === 'hidden'
}

$(function () {

    /*
    circleProgress1.value = 200 - 100; // health
    circleProgress2.value = 50; // armor
    circleProgress3.value = 50 // stamina
    circleProgress4.value = 50; // hunger
    circleProgress5.value = 50; //thirst
    $(".h2o-hud-container").css("display", "flex");
    $(".minimap").css("display", "flex");
    */

    $(".circle-progress-text1").css("display", 'none');
    $(".circle-progress-text2").css("display", 'none');
    $(".circle-progress-text3").css("display", 'none');
    $(".circle-progress-text4").css("display", 'none');
    $(".circle-progress-text5").css("display", 'none');

    /*
    $('.progress1').fadeIn();
    $(".progress1").css("display", 'inline-block');
    fillWater(circleProgress1.value, "progress1", "#FF0000");

    $('.progress2').fadeIn();
    $(".progress2").css("display", 'inline-block');
    fillWater(circleProgress2.value, "progress2", "#1166ff ");

    $('.progress3').fadeIn();
    $(".progress3").css("display", 'inline-block');
    fillWater(circleProgress3.value, "progress3", "#4efd54");

    $('.progress4').fadeIn();
    $(".progress4").css("display", 'inline-block');
    fillWater(circleProgress4.value, "progress4", "#ffa600");

    $('.progress5').fadeIn();
    $(".progress5").css("display", 'inline-block');
    fillWater(circleProgress5.value, "progress5", "#04d9ff");
    */

    setInterval(() => {

        if (isHudDisplayed) {
            if (isHidden(document.querySelector('.circle-progress-text1'))) {
                $('.fa-heart').fadeOut();
                $('.circle-progress-text1').fadeIn();
            } else {
                $('.circle-progress-text1').fadeOut();
                $('.fa-heart').fadeIn();
            }
            if (isHidden(document.querySelector('.circle-progress-text2'))) {
                $('.fa-shield-alt').fadeOut();
                $('.circle-progress-text2').fadeIn();
            } else {
                $('.circle-progress-text2').fadeOut();
                $('.fa-shield-alt').fadeIn();
            }
            if (isHidden(document.querySelector('.circle-progress-text3'))) {
                $('.fa-lungs').fadeOut();
                $('.circle-progress-text3').fadeIn();
            } else {
                $('.circle-progress-text3').fadeOut();
                $('.fa-lungs').fadeIn();
            }
            if (isHidden(document.querySelector('.circle-progress-text4'))) {
                $('.fa-hamburger').fadeOut();
                $('.circle-progress-text4').fadeIn();
            } else {
                $('.circle-progress-text4').fadeOut();
                $('.fa-hamburger').fadeIn();
            }
            if (isHidden(document.querySelector('.circle-progress-text5'))) {
                $('.fa-tint').fadeOut();
                $('.circle-progress-text5').fadeIn();
            } else {
                $('.circle-progress-text5').fadeOut();
                $('.fa-tint').fadeIn();
            }
        }
    }, 3000)//1500ms
})

$(function () {
    setInterval(() => {
        var today = new Date();
        var minutes = today.getMinutes();
        var hour = today.getHours();
        if (minutes <= 9) {
            minutes = '0' + minutes
        }
        today = hour + ':' + minutes
        //console.log(today);
        $('#date').html(today);
    }, 1000 * 5)
}
)
