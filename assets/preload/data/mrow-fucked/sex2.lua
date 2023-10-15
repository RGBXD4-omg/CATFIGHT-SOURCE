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
end