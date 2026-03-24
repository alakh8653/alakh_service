import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seed...');

  // ---- Super Admin ----
  const superAdminPassword = await bcrypt.hash('Admin@123456', 12);
  const superAdmin = await prisma.user.upsert({
    where: { email: 'superadmin@alakhservice.com' },
    update: {},
    create: {
      name: 'Super Admin',
      email: 'superadmin@alakhservice.com',
      phone: '+919000000000',
      passwordHash: superAdminPassword,
      role: 'SUPER_ADMIN',
      isActive: true,
      isVerified: true,
    },
  });
  console.log(`✅ Super admin: ${superAdmin.email}`);

  // ---- Admin ----
  const adminPassword = await bcrypt.hash('Admin@123456', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@alakhservice.com' },
    update: {},
    create: {
      name: 'Admin User',
      email: 'admin@alakhservice.com',
      phone: '+919000000001',
      passwordHash: adminPassword,
      role: 'ADMIN',
      isActive: true,
      isVerified: true,
    },
  });
  console.log(`✅ Admin: ${admin.email}`);

  // ---- Categories ----
  const categories = [
    { name: 'Cleaning', slug: 'cleaning', icon: '🧹', description: 'Home and office cleaning services' },
    { name: 'Plumbing', slug: 'plumbing', icon: '🔧', description: 'Plumbing repair and installation' },
    { name: 'Electrical', slug: 'electrical', icon: '⚡', description: 'Electrical repair and wiring' },
    { name: 'Carpentry', slug: 'carpentry', icon: '🪚', description: 'Furniture and woodwork repair' },
    { name: 'Painting', slug: 'painting', icon: '🎨', description: 'Home and office painting' },
    { name: 'Appliance Repair', slug: 'appliance-repair', icon: '🔌', description: 'Repair of home appliances' },
    { name: 'Pest Control', slug: 'pest-control', icon: '🐛', description: 'Pest and insect control services' },
    { name: 'AC Service', slug: 'ac-service', icon: '❄️', description: 'AC installation and servicing' },
    { name: 'Beauty & Wellness', slug: 'beauty-wellness', icon: '💆', description: 'Salon and spa at home' },
    { name: 'Tutoring', slug: 'tutoring', icon: '📚', description: 'Home tutoring and coaching' },
  ];

  const createdCategories: Record<string, string> = {};
  for (const cat of categories) {
    const created = await prisma.category.upsert({
      where: { slug: cat.slug },
      update: {},
      create: {
        ...cat,
        isActive: true,
        sortOrder: categories.indexOf(cat),
      },
    });
    createdCategories[cat.slug] = created.id;
    console.log(`✅ Category: ${cat.name}`);
  }

  // ---- Demo Provider User ----
  const providerPassword = await bcrypt.hash('Provider@123', 12);
  const providerUser = await prisma.user.upsert({
    where: { email: 'provider@alakhservice.com' },
    update: {},
    create: {
      name: 'Ramesh Kumar',
      email: 'provider@alakhservice.com',
      phone: '+919100000001',
      passwordHash: providerPassword,
      role: 'PROVIDER',
      isActive: true,
      isVerified: true,
    },
  });

  const provider = await prisma.provider.upsert({
    where: { userId: providerUser.id },
    update: {},
    create: {
      userId: providerUser.id,
      businessName: 'Ramesh Cleaning Services',
      bio: 'Professional cleaning expert with 5+ years of experience.',
      skills: ['Deep Cleaning', 'Bathroom Cleaning', 'Kitchen Cleaning'],
      yearsOfExperience: 5,
      isApproved: true,
      isAvailable: true,
      serviceLat: 28.6139,
      serviceLng: 77.2090,
      serviceRadiusKm: 15,
      commissionPercent: 15,
    },
  });
  console.log(`✅ Provider: ${providerUser.email}`);

  // ---- Provider Availability ----
  const days: Array<'MON' | 'TUE' | 'WED' | 'THU' | 'FRI' | 'SAT'> = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  for (const day of days) {
    await prisma.availability.upsert({
      where: { providerId_day: { providerId: provider.id, day } },
      update: {},
      create: {
        providerId: provider.id,
        day,
        startTime: '09:00',
        endTime: '18:00',
        isActive: true,
      },
    });
  }
  console.log('✅ Provider availability set');

  // ---- Demo Services ----
  const services = [
    {
      name: 'Home Deep Cleaning',
      slug: 'home-deep-cleaning',
      categorySlug: 'cleaning',
      basePrice: 799,
      description: 'Complete deep cleaning of your home including all rooms, kitchen, and bathrooms.',
      tags: ['deep clean', 'home', 'all rooms'],
    },
    {
      name: 'Bathroom Cleaning',
      slug: 'bathroom-cleaning',
      categorySlug: 'cleaning',
      basePrice: 299,
      description: 'Professional bathroom cleaning and sanitization.',
      tags: ['bathroom', 'clean', 'sanitize'],
    },
    {
      name: 'Kitchen Chimney Cleaning',
      slug: 'kitchen-chimney-cleaning',
      categorySlug: 'cleaning',
      basePrice: 499,
      description: 'Thorough cleaning of kitchen chimney and filters.',
      tags: ['chimney', 'kitchen', 'deep clean'],
    },
  ];

  for (const svc of services) {
    await prisma.service.upsert({
      where: { slug: svc.slug },
      update: {},
      create: {
        providerId: provider.id,
        categoryId: createdCategories[svc.categorySlug]!,
        name: svc.name,
        slug: svc.slug,
        description: svc.description,
        basePrice: svc.basePrice,
        priceUnit: 'per visit',
        serviceType: 'HOME',
        duration: 90,
        tags: svc.tags,
        isActive: true,
      },
    });
    console.log(`✅ Service: ${svc.name}`);
  }

  // ---- Demo Customer ----
  const customerPassword = await bcrypt.hash('Customer@123', 12);
  const customer = await prisma.user.upsert({
    where: { email: 'customer@alakhservice.com' },
    update: {},
    create: {
      name: 'Priya Sharma',
      email: 'customer@alakhservice.com',
      phone: '+919200000001',
      passwordHash: customerPassword,
      role: 'CUSTOMER',
      isActive: true,
      isVerified: true,
    },
  });
  console.log(`✅ Customer: ${customer.email}`);

  // ---- Demo Address ----
  await prisma.address.upsert({
    where: { id: 'demo-address-1' },
    update: {},
    create: {
      id: 'demo-address-1',
      userId: customer.id,
      label: 'Home',
      street: 'Flat 101, Green View Apartments',
      city: 'New Delhi',
      state: 'Delhi',
      country: 'India',
      zipCode: '110001',
      lat: 28.6139,
      lng: 77.2090,
      isDefault: true,
    },
  });

  // ---- System Config ----
  const configs = [
    { key: 'app.maintenance', value: 'false', type: 'boolean', group: 'app', label: 'Maintenance Mode', isPublic: true },
    { key: 'app.version', value: '1.0.0', type: 'string', group: 'app', label: 'App Version', isPublic: true },
    { key: 'booking.min_advance_hours', value: '2', type: 'number', group: 'booking', label: 'Minimum Advance Hours' },
    { key: 'booking.max_advance_days', value: '30', type: 'number', group: 'booking', label: 'Maximum Advance Days' },
    { key: 'platform.commission_percent', value: '15', type: 'number', group: 'platform', label: 'Default Commission %' },
    { key: 'platform.gst_percent', value: '18', type: 'number', group: 'platform', label: 'GST %' },
    { key: 'wallet.min_withdrawal', value: '100', type: 'number', group: 'wallet', label: 'Minimum Withdrawal Amount' },
  ];

  for (const config of configs) {
    await prisma.systemConfig.upsert({
      where: { key: config.key },
      update: {},
      create: config,
    });
  }
  console.log('✅ System configs created');

  // ---- Promo Codes ----
  await prisma.promoCode.upsert({
    where: { code: 'WELCOME50' },
    update: {},
    create: {
      code: 'WELCOME50',
      description: '50% off on first booking',
      discountType: 'PERCENT',
      discountValue: 50,
      minOrderAmount: 299,
      maxDiscount: 200,
      usageLimit: 1000,
      perUserLimit: 1,
      isActive: true,
      validUntil: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000),
    },
  });

  await prisma.promoCode.upsert({
    where: { code: 'FLAT100' },
    update: {},
    create: {
      code: 'FLAT100',
      description: '₹100 flat discount',
      discountType: 'FLAT',
      discountValue: 100,
      minOrderAmount: 499,
      usageLimit: 500,
      perUserLimit: 2,
      isActive: true,
      validUntil: new Date(Date.now() + 180 * 24 * 60 * 60 * 1000),
    },
  });
  console.log('✅ Promo codes created');

  console.log('\n🎉 Database seed completed successfully!');
  console.log('\n📋 Demo Credentials:');
  console.log('  Super Admin: superadmin@alakhservice.com / Admin@123456');
  console.log('  Admin:       admin@alakhservice.com / Admin@123456');
  console.log('  Provider:    provider@alakhservice.com / Provider@123');
  console.log('  Customer:    customer@alakhservice.com / Customer@123');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
