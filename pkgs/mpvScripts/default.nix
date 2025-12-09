{ callPackage, upstreamMpvScripts }:
{
  interSubs = callPackage ./interSubs { };
  whisper-subs = callPackage ./whisper-subs { };
}
