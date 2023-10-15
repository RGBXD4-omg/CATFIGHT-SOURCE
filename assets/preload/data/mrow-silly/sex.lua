function onCreate()
    setProperty('skipCountdown', true)
end

function onCreatePost()
    setProperty('camGame.alpha', 0)
end

function onBeatHit()
    if curBeat == 3 then
        doTweenAlpha('v', 'camGame', 1, crochet/1000)
    end
    if curBeat == 292 then
        doTweenAngle('v', 'lyricsTxt', 56, 2, 'sineInOut')
        doTweenX('v2', 'lyricsTxt', -400, 2, 'sineInOut')
        doTweenY('v3', 'lyricsTxt', -200, 3, 'sineInOut')
    end 
end