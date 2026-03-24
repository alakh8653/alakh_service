import slugify from 'slugify';
import { v4 as uuidv4 } from 'uuid';

const SLUGIFY_OPTIONS = {
  lower: true,
  strict: true,
  trim: true,
};

export function generateSlug(text: string): string {
  return slugify(text, SLUGIFY_OPTIONS);
}

export function generateUniqueSlug(text: string): string {
  const base = slugify(text, SLUGIFY_OPTIONS);
  const suffix = uuidv4().split('-')[0];
  return `${base}-${suffix}`;
}

export function ensureUniqueSlug(baseSlug: string, existingSlugs: string[]): string {
  if (!existingSlugs.includes(baseSlug)) return baseSlug;

  let counter = 2;
  let candidate = `${baseSlug}-${counter}`;
  while (existingSlugs.includes(candidate)) {
    counter++;
    candidate = `${baseSlug}-${counter}`;
  }
  return candidate;
}
