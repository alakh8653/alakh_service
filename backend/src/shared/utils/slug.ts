export const toSlug = (text: string): string => {
  return text
    .toLowerCase()
    .trim()
    .replace(/[^\w\s-]/g, '')
    .replace(/[\s_-]+/g, '-')
    .replace(/^-+|-+$/g, '');
};

export const toUniqueSlug = (text: string, suffix?: string | number): string => {
  const base = toSlug(text);
  return suffix !== undefined ? `${base}-${suffix}` : base;
};
