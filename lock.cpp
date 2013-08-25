#include "lock.h"
#include <aknkeylock.h>
#include <hwrmlight.h>
#include <e32svr.h>

lock::lock(QObject *parent) :
    QObject(parent)
{
    light = CHWRMLight::NewL();
}

void lock::lockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.EnableKeyLock();
    aKeyLock.Close();
}

void lock::unlockDevice() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    aKeyLock.DisableKeyLock();
    aKeyLock.Close();
}

bool lock::isLocked() {
    RAknKeyLock aKeyLock;
    aKeyLock.Connect();
    bool smiercCierpienie;
    smiercCierpienie = aKeyLock.IsKeyLockEnabled();
    aKeyLock.Close();
    return smiercCierpienie;
}

void lock::blink() {
    light->LightBlinkL(CHWRMLight::EPrimaryDisplay, KHWRMInfiniteDuration, KHWRMDefaultCycleTime, KHWRMDefaultCycleTime*2, KHWRMDefaultIntensity);
    light->LightBlinkL(CHWRMLight::EPrimaryKeyboard, KHWRMInfiniteDuration, KHWRMDefaultCycleTime/2, KHWRMDefaultCycleTime*2, KHWRMDefaultIntensity);
    //delete light;
}
