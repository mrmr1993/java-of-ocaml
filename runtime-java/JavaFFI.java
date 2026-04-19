import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

/**
 * Reflective fallback for the Java FFI escape hatch exposed via
 * {@code Java.Unsafe} in OCaml. The PPX-generated path emits direct
 * {@code invoke*} / {@code getfield} / {@code new} instructions when
 * the class, member, and descriptor are all known at compile time;
 * this class handles the cases where they're computed at runtime —
 * for instance, building a method name from user input or picking
 * between overloads at dispatch time.
 *
 * <p>All lookups are done by name + arity; we pick the first matching
 * overload whose declared arity matches the argument count. Argument
 * type matching is deliberately loose — OCaml-side callers use
 * {@code Object[]} for flexibility, and primitive arguments are
 * already boxed at that point. This is sufficient for most
 * non-overloaded use; callers that need precise overload resolution
 * should bind an {@code external} with a specific descriptor
 * instead.
 */
public final class JavaFFI {
    private JavaFFI() {}

    public static Object callVirtual(Object obj, String name, Object[] args) {
        try {
            Method m = findMethod(obj.getClass(), name, args.length, false);
            if (m == null) throw new NoSuchMethodException(obj.getClass().getName() + "." + name);
            m.setAccessible(true);
            return m.invoke(obj, args);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static Object callStatic(String className, String name, Object[] args) {
        try {
            Class<?> cls = Class.forName(className.replace('/', '.'));
            Method m = findMethod(cls, name, args.length, true);
            if (m == null) throw new NoSuchMethodException(className + "." + name);
            m.setAccessible(true);
            return m.invoke(null, args);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static Object newInstance(String className, Object[] args) {
        try {
            Class<?> cls = Class.forName(className.replace('/', '.'));
            for (Constructor<?> c : cls.getDeclaredConstructors()) {
                if (c.getParameterCount() == args.length) {
                    c.setAccessible(true);
                    return c.newInstance(args);
                }
            }
            throw new NoSuchMethodException("no ctor with arity " + args.length + " on " + className);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static Object getField(Object obj, String name) {
        try {
            Field f = findField(obj.getClass(), name);
            if (f == null) throw new NoSuchFieldException(obj.getClass().getName() + "." + name);
            f.setAccessible(true);
            return f.get(obj);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static void setField(Object obj, String name, Object value) {
        try {
            Field f = findField(obj.getClass(), name);
            if (f == null) throw new NoSuchFieldException(obj.getClass().getName() + "." + name);
            f.setAccessible(true);
            f.set(obj, value);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static Object getStaticField(String className, String name) {
        try {
            Class<?> cls = Class.forName(className.replace('/', '.'));
            Field f = findField(cls, name);
            if (f == null) throw new NoSuchFieldException(className + "." + name);
            f.setAccessible(true);
            return f.get(null);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static void setStaticField(String className, String name, Object value) {
        try {
            Class<?> cls = Class.forName(className.replace('/', '.'));
            Field f = findField(cls, name);
            if (f == null) throw new NoSuchFieldException(className + "." + name);
            f.setAccessible(true);
            f.set(null, value);
        } catch (ReflectiveOperationException e) {
            throw new RuntimeException(e);
        }
    }

    public static boolean instanceOf(Object obj, String className) {
        try {
            return Class.forName(className.replace('/', '.')).isInstance(obj);
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    private static Method findMethod(Class<?> cls, String name, int arity, boolean wantStatic) {
        for (Method m : cls.getMethods()) {
            if (!m.getName().equals(name)) continue;
            if (m.getParameterCount() != arity) continue;
            if (wantStatic != java.lang.reflect.Modifier.isStatic(m.getModifiers())) continue;
            return m;
        }
        for (Class<?> c = cls; c != null; c = c.getSuperclass()) {
            for (Method m : c.getDeclaredMethods()) {
                if (!m.getName().equals(name)) continue;
                if (m.getParameterCount() != arity) continue;
                if (wantStatic != java.lang.reflect.Modifier.isStatic(m.getModifiers())) continue;
                return m;
            }
        }
        return null;
    }

    private static Field findField(Class<?> cls, String name) {
        try { return cls.getField(name); } catch (NoSuchFieldException e) { /* fall through */ }
        for (Class<?> c = cls; c != null; c = c.getSuperclass()) {
            try { return c.getDeclaredField(name); } catch (NoSuchFieldException e) { /* next */ }
        }
        return null;
    }
}
