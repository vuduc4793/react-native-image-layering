import { NativeModules, Platform } from 'react-native';
import type { CombinedImage } from './types';

const LINKING_ERROR =
  `The package 'react-native-image-layering' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ImageLayering = NativeModules.ImageLayering
  ? NativeModules.ImageLayering
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function multiply(a: number, b: number): Promise<number> {
  return ImageLayering.multiply(a, b);
}

export function imageLayering(imageOne: string, imageTwo: string): Promise<CombinedImage> {
  return ImageLayering.imageLayering(imageOne, imageTwo);
}